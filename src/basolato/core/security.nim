import asynchttpserver, asyncdispatch, httpcore, json, strutils, times, random, strformat, os
# framework
import ./baseEnv, utils
# 3rd party
import flatdb, nimAES

randomize()

# ========= Encrypt ==================
proc randStr(n:varargs[int]):string =
  randomize()
  var n = n.sample()
  for _ in 1..n:
    add(result, char(rand(int('0')..int('z'))))

proc commonCtr(input:string):string =
  var ctx: AESContext
  zeroMem(addr(ctx), sizeof(ctx))
  discard ctx.setEncodeKey(SECRET_KEY)
  var offset = 0
  var counter: array[0..15, uint8]
  var nonce = cast[cstring](addr(counter[0]))
  zeroMem(addr(counter), sizeof(counter))
  return ctx.cryptCTR(offset, nonce, input)

proc encryptCtr*(input:string):string =
  var input = randStr(16) & input
  input = input.commonCtr().toHex()
  return input

proc decryptCtr*(input:string):string =
  let input = input.parseHexStr().commonCtr()
  return input[16..high(input)]


# ========= Flat DB ==================
type SessionDb = ref object
  conn: FlatDb
  token: string

proc clean(this:SessionDb) {.async.} =
  if not IS_SESSION_MEMORY and SESSION_TIME.len > 0:
    var buffer = newSeq[string]()
    for line in SESSION_DB_PATH.lines:
      if line.len == 0: break
      let lineJson = line.parseJson()
      if lineJson.hasKey("last_access"):
        let lastAccess = lineJson["last_access"].getStr().parse("yyyy-MM-dd\'T\'HH:mm:sszzz")
        let expireAt = lastAccess + SESSION_TIME.parseInt().minutes
        if now() <= expireAt:
          buffer.add(line)
    if buffer.len > 0:
      buffer.add("")
      writeFile(SESSION_DB_PATH, buffer.join("\n"))

proc checkTokenValid(db:FlatDb, token:string) {.async.} =
  try:
    discard db[token]
  except:
    raise newException(Exception, "Invalid session id")

proc createParentFlatDbDir():Future[FlatDb] {.async.} =
  if not dirExists(SESSION_DB_PATH.parentDir()):
    createDir(SESSION_DB_PATH.parentDir())
  return newFlatDb(SESSION_DB_PATH, IS_SESSION_MEMORY)

proc newSessionDb*(sessionId=""):Future[SessionDb] {.async.} =
  let db = await createParentFlatDbDir()
  defer: db.close()
  var sessionDb: SessionDb
  # clean expired session probability of 1/100
  if rand(1..100) == 1:
    await sessionDb.clean()
  discard db.load()
  try:
    var token = sessionId.decryptCtr()
    await db.checkTokenValid(token)
    sessionDb = SessionDb(conn: db, token:token)
  except:
    let token = db.append(newJObject())
    sessionDb = SessionDb(conn: db, token:token)
  return sessionDb

proc checkSessionIdValid*(sessionId=""):Future[bool] {.async.} =
  let db = await createParentFlatDbDir()
  defer: db.close()
  discard db.load()
  try:
    var token = sessionId.decryptCtr()
    await db.checkTokenValid(token)
    return true
  except:
    return false

proc getToken*(this:SessionDb):Future[string] {.async.} =
  return this.token.encryptCtr()

proc set*(this:SessionDb, key, value:string):Future[SessionDb] {.async.} =
  let db = this.conn
  defer: db.close()
  db[this.token][key] = %value
  db.flush()
  return this

proc some*(this:SessionDb, key:string):Future[bool] {.async.} =
  try:
    let db = this.conn
    defer: db.close()
    if db[this.token]{key}.isNil():
      return false
    else:
      return true
  except:
    return false

proc get*(this:SessionDb, key:string):Future[string] {.async.} =
  let db = this.conn
  defer: db.close()
  return db[this.token]{key}.getStr("")

proc delete*(this:SessionDb, key:string):Future[SessionDb] {.async.} =
  let db = this.conn
  defer: db.close()
  let row = db[this.token]
  if row.hasKey(key):
    row.delete(key)
    db.flush()
  return this

proc destroy*(this:SessionDb) {.async.} =
  this.conn.delete(this.token)
  defer: this.conn.close()


# ========= Session ==================
type
  SessionType* = enum
    File
    Redis

  Session* = ref object
    db: SessionDb

proc newSession*(token="", typ:SessionType=File):Future[Session] {.async.} =
  if typ == File:
    return Session(db:await newSessionDb(token))

proc db*(this:Session):SessionDb =
  return this.db

proc getToken*(this:Session):Future[string] {.async.} =
  return await this.db.getToken()

proc set*(this:Session, key, value:string) {.async.} =
  discard await this.db.set(key, value)

proc some*(this:Session, key:string):Future[bool] {.async.} =
  return await this.db.some(key)

proc get*(this:Session, key:string):Future[string] {.async.} =
  return await this.db.get(key)

proc delete*(this:Session, key:string) {.async.} =
  discard await this.db.delete(key)

proc destroy*(this:Session) {.async.} =
  await this.db.destroy()


# ========== Cookie ====================
type
  CookieData* = ref object
    name:string
    value:string
    expire:string
    sameSite:SameSite
    secure:bool
    httpOnly:bool
    domain:string
    path:string

  Cookie* = ref object
    request:Request
    cookies*:seq[CookieData]


proc timeForward*(num:int, timeUnit:TimeUnit):DateTime =
  case timeUnit
  of Years:
    return getTime().utc + initTimeInterval(years = num)
  of Months:
    return getTime().utc + initTimeInterval(months = num)
  of Weeks:
    return getTime().utc + initTimeInterval(weeks = num)
  of Days:
    return getTime().utc + initTimeInterval(days = num)
  of Hours:
    return getTime().utc + initTimeInterval(hours = num)
  of Minutes:
    return getTime().utc + initTimeInterval(minutes = num)
  of Seconds:
    return getTime().utc + initTimeInterval(seconds = num)
  of Milliseconds:
    return getTime().utc + initTimeInterval(milliseconds = num)
  of Microseconds:
    return getTime().utc + initTimeInterval(microseconds = num)
  of Nanoseconds:
    return getTime().utc + initTimeInterval(nanoseconds = num)

proc toCookieStr*(this:CookieData):string =
  makeCookie(this.name, this.value, this.expire, this.domain, this.path,
              this.secure, this.httpOnly, this.sameSite)


proc newCookieData*(name, value:string, expire:DateTime, sameSite: SameSite=Lax,
      secure, httpOnly=false, domain = "", path = "/"):CookieData =
  let f = initTimeFormat("ddd',' dd MMM yyyy HH:mm:ss 'GMT'")
  let expireStr = format(expire.utc, f)
  when defined(release):
    let secure, httpOnly = true
  CookieData(name:name, value:value,expire:expireStr, sameSite:sameSite,
    secure:secure, httpOnly:httpOnly, domain:domain, path:path)

proc newCookieData*(name, value:string, expire="", sameSite: SameSite=Lax,
      secure, httpOnly=false, domain = "", path = "/"):CookieData =
  when defined(release):
    let secure, httpOnly = true
  CookieData(name:name, value:value,expire:expire, sameSite:sameSite,
    secure:secure, httpOnly:httpOnly, domain:domain, path:path)

proc newCookie*(request:Request):Cookie =
  return Cookie(request:request, cookies:newSeq[CookieData](0))

proc cookies(request:Request):Cookie =
  return request.newCookie()

proc get*(this:Cookie, name:string):string =
  result = ""
  if not this.request.headers.hasKey("Cookie"):
    return result
  let cookiesStrArr = this.request.headers["Cookie"].split("; ")
  for row in cookiesStrArr:
    let rowArr = row.split("=")
    if rowArr[0] == name:
      result = rowArr[1]
      break

proc hasKey*(this:Cookie, name:string):bool =
  if this.get(name).len > 0:
    return true
  else:
    return false

proc set*(this:var Cookie, name, value: string, expire:DateTime,
      sameSite: SameSite=Lax, secure = false, httpOnly = false, domain = "",
      path = "/") =
  let f = initTimeFormat("ddd',' dd MMM yyyy HH:mm:ss 'GMT'")
  let expireStr = format(expire.utc, f)
  this.cookies.add(
    CookieData(name:name, value:value, expire:expireStr, sameSite:sameSite,
      secure:secure, httpOnly:httpOnly, domain:domain, path:path)
  )

proc set*(this:var Cookie, name, value: string, sameSite: SameSite=Lax,
      secure = false, httpOnly = false, domain = "", path = "/") =
  let expires = timeForward(CSRF_TIME, Minutes)
  let f = initTimeFormat("ddd',' dd MMM yyyy HH:mm:ss 'GMT'")
  let expireStr = format(expires.utc, f)
  this.cookies.add(
    CookieData(name:name, value:value, expire:expireStr, sameSite:sameSite,
      secure:secure, httpOnly:httpOnly, domain:domain, path:path)
  )

proc updateExpire*(this:var Cookie, name:string, num:int,
                    timeUnit:TimeUnit, path="/") =
  let f = initTimeFormat("ddd',' dd MMM yyyy HH:mm:ss 'GMT'")
  let expireStr = format(timeForward(num, timeUnit).utc, f)
  if this.request.headers.hasKey("Cookie"):
    let cookiesStrArr = this.request.headers["Cookie"].split("; ")
    for i, row in cookiesStrArr:
      let rowArr = row.split("=")
      if rowArr[0] == name:
        this.cookies.add(newCookieData(rowArr[0], rowArr[1], expire=expireStr))
        break

proc delete*(this:var Cookie, key:string, path="/") =
  this.cookies.add(
    newCookieData(name=key, value="", expire=timeForward(-1, Days), path=path)
  )

proc destroy*(this:var Cookie, path="/") =
  if this.request.headers.hasKey("Cookie"):
    let cookiesStrArr = this.request.headers["Cookie"].split("; ")
    for row in cookiesStrArr:
      let name = row.split("=")[0]
      this.cookies.add(
        newCookieData(name=name, value="", expire=timeForward(-1, Days), path=path)
      )


# ========== Auth ====================
type Auth* = ref object
  session*:Session

proc newAuth*(request:Request):Future[Auth] {.async.} =
  ## use in constructor
  var sessionId = newCookie(request).get("session_id")
  if await checkSessionIdValid(sessionId):
    let session = await newSession(sessionId)
    await session.set("last_access", $getTime())
    return Auth(session:session)
  else:
    return Auth()

proc newAuth*():Future[Auth] {.async.} =
  ## use in action method
  let session = await newSession()
  await session.set("isLogin", "false")
  await session.set("last_access", $getTime())
  return Auth(session:session)

# proc newAuthIfInvalid*(request:Request):Future[Auth] {.async.} =
#   var auth:Auth
#   if not request.cookies.hasKey("session_id"):
#     auth = await newAuth()
#   else:
#     var sessionId = newCookie(request).get("session_id")
#     try:
#       auth = Auth(session:await newSession(sessionId))
#     except:
#       auth = await newAuth()
#   return auth


proc getToken*(this:Auth):Future[string] {.async.} =
  return await this.session.getToken()

proc set*(this:Auth, key, value:string) {.async.} =
  await this.session.set(key, value)

proc some*(this:Auth, key:string):Future[bool] {.async.} =
  if this.isNil:
    return false
  elif this.session.isNil:
    return false
  else:
    return await this.session.some(key)

proc get*(this:Auth, key:string):Future[string] {.async.} =
  if await this.session.some("isLogin"):
    return await this.session.get(key)
  else:
    return ""

proc delete*(this:Auth, key:string) {.async.} =
  await this.session.delete(key)

proc destroy*(this:Auth) {.async.} =
  await this.session.destroy()

proc login*(this:Auth) {.async.} =
  if this.session.isNil:
    this.session = await newSession()
    await this.session.set("isLogin", "true")
    await this.session.set("last_access", $getTime())
  else:
    await this.set("isLogin", "true")

proc anonumousCreateSession*(this:Auth):Future[bool] {.async.} =
  if this.session.isNil or not await checkSessionIdValid(await this.getToken):
    this.session = await newSession()
    await this.set("isLogin", "false")
    await this.set("last_access", $getTime())
    return true
  else:
    return false

proc logout*(this:Auth) {.async.} =
  await this.destroy()

proc isLogin*(this:Auth):Future[bool] {.async.} =
  if await this.some("isLogin"):
    return parseBool(await this.session.get("isLogin"))
  else:
    return false


# ========== Flash ====================
proc setFlash*(this:Auth, key, value:string) {.async.} =
  let key = "flash_" & key
  await this.set(key, value)

proc hasFlash*(this:Auth, key:string):Future[bool] {.async.} =
  result = false
  for k, v in this.session.db.conn[this.session.db.token].pairs:
    if k.contains("flash_" & key):
      result = true
      break

proc getFlash*(this:Auth):Future[JsonNode] {.async.} =
  result = newJObject()
  if await this.isLogin:
    for key, val in this.session.db.conn[this.session.db.token].pairs:
      if key.contains("flash_"):
        var newKey = key
        newKey.delete(0, 5)
        result[newKey] = val
        await this.delete(key)


# ========== Token ====================
type Token* = ref object
  token:string


proc newToken*(token:string):Token =
  if token.len > 0:
    return Token(token:token)
  var token = $(getTime().toUnix().int())
  token = token.encryptCtr()
  return Token(token:token)

proc getToken*(this:Token):string =
  return this.token

proc toTimestamp*(this:Token): int =
  return this.getToken().decryptCtr().parseInt()


# ========== CsrfToken ====================
type CsrfToken* = ref object
  token:Token


proc newCsrfToken*(token=""):CsrfToken =
  return CsrfToken(token: newToken(token))

proc getToken*(this:CsrfToken): string =
  this.token.getToken()

proc csrfToken*(token=""):string =
  var token = newCsrfToken(token).getToken()
  return &"""<input type="hidden" name="csrf_token" value="{token}">"""

proc checkCsrfTimeout*(this:CsrfToken):bool =
  var timestamp:int
  try:
    timestamp = this.token.toTimestamp()
  except:
    raise newException(Exception, "Invalid csrf token")

  if getTime().toUnix > timestamp + CSRF_TIME * 60:
    raise newException(Exception, "Timeout")
  return true