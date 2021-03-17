import asynchttpserver, asyncdispatch, httpcore, json, strutils, times, random, strformat, os
# framework
import ./baseEnv, utils
# 3rd party
import flatdb, nimAES

when SESSION_TYPE == "redis":
  import redis


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
  if input.len == 0: return ""
  try:
    let input = input.parseHexStr().commonCtr()
    return input[16..high(input)]
  except:
    return ""


# ========== Token ====================
type Token* = ref object
  token:string


proc newToken*(token=""):Token =
  if token.len > 0:
    return Token(token:token)
  var token = $(getTime().toUnix().int())
  token = token.encryptCtr()
  return Token(token:token)

func getToken*(self:Token):string =
  return self.token

proc toTimestamp*(self:Token): int =
  return self.getToken().decryptCtr().parseInt()


# ========== Session DB ====================
when SESSION_TYPE == "redis":
  # ========== Redis ====================
  type SessionDb = ref object
    conn: AsyncRedis
    token: string

  const REDIS_IP = SESSION_DB_PATH.split(":")[0]
  const REDIS_PORT = SESSION_DB_PATH.split(":")[1].parseInt

  proc newSessionDb*(sessionId=""):Future[SessionDb] {.async.} =
    let token =
      if sessionId.len == 0:
        newToken().getToken()
      else:
        sessionId

    let conn = await openAsync(REDIS_IP, Port(REDIS_PORT))
    discard await conn.hSet(token, "last_access", $getTime())
    discard await conn.expire(token, SESSION_TIME * 60)

    return SessionDb(
      conn: conn,
      token: token
    )

  proc checkSessionIdValid*(sessionId:string):Future[bool] {.async.} =
    let conn = await openAsync(REDIS_IP, Port(REDIS_PORT))
    if await conn.hExists(sessionId, "last_access"):
      return true
    else:
      return false

  proc getToken*(self:SessionDb):Future[string] {.async.} =
    return self.token

  proc set*(self:SessionDb, key, value: string) {.async.} =
    discard await self.conn.hSet(self.token, key, value)

  proc some*(self:SessionDb, key:string):Future[bool] {.async.} =
    return await self.conn.hExists(self.token, key)

  proc get*(self:SessionDb, key:string):Future[string] {.async.} =
    return await self.conn.hGet(self.token, key)

  proc getRows*(self:SessionDb):Future[JsonNode] {.async.} =
    let rows = await self.conn.hGetAll(self.token)
    # list to JsonNode
    var str = "{"
    for i, val in rows:
      if i == 0 or i mod 2 == 0:
        str.add(&"\"{val}\":")
      else:
        str.add(&"\"{val}\", ")
    str.add("}")
    return str.parseJson

  proc delete*(self:SessionDb, key:string) {.async.} =
    discard await self.conn.hDel(self.token, key)

  proc destroy*(self:SessionDb) {.async.} =
    discard await self.conn.del(@[self.token])

else:
  # ========= Flat DB ==================
  type SessionDb = ref object
    conn: FlatDb
    token: string

  proc clean(self:SessionDb) {.async.} =
    var buffer = newSeq[string]()
    for line in SESSION_DB_PATH.lines:
      if line.len == 0: break
      let lineJson = line.parseJson()
      if lineJson.hasKey("last_access"):
        let lastAccess = lineJson["last_access"].getStr().parse("yyyy-MM-dd\'T\'HH:mm:sszzz")
        let expireAt = lastAccess + SESSION_TIME.minutes
        if now() <= expireAt:
          buffer.add(line)
    if buffer.len > 0:
      buffer.add("")
      writeFile(SESSION_DB_PATH, buffer.join("\n"))

  proc isTokenValid(db:FlatDb, token:string):Future[bool] {.async.} =
    return db.exists(token)

  proc createParentFlatDbDir():Future[FlatDb] {.async.} =
    if not dirExists(SESSION_DB_PATH.parentDir()):
      createDir(SESSION_DB_PATH.parentDir())
    return newFlatDb(SESSION_DB_PATH, false)

  proc newSessionDb*(sessionId=""):Future[SessionDb] {.async.} =
    let db = await createParentFlatDbDir()
    defer: db.close()
    var sessionDb: SessionDb
    # clean expired session probability of 1/100
    if rand(1..100) == 1:
      await sessionDb.clean()
    discard db.load()
    var token = sessionId.decryptCtr()
    if not await db.isTokenValid(token):
      token = db.append(newJObject())
    sessionDb = SessionDb(conn: db, token:token)
    return sessionDb

  proc checkSessionIdValid*(sessionId=""):Future[bool] {.async.} =
    let db = await createParentFlatDbDir()
    defer: db.close()
    discard db.load()
    var token = sessionId.decryptCtr()
    return await db.isTokenValid(token)

  proc getToken*(self:SessionDb):Future[string] {.async.} =
    return self.token.encryptCtr()

  proc set*(self:SessionDb, key, value:string) {.async.} =
    let db = self.conn
    defer: db.close()
    db[self.token][key] = %value
    db.flush()

  proc some*(self:SessionDb, key:string):Future[bool] {.async.} =
    try:
      let db = self.conn
      defer: db.close()
      if db[self.token]{key}.isNil():
        return false
      else:
        return true
    except:
      return false

  proc get*(self:SessionDb, key:string):Future[string] {.async.} =
    let db = self.conn
    defer: db.close()
    return db[self.token]{key}.getStr("")

  proc getRows*(self:SessionDb):Future[JsonNode] {.async.} =
    return %*(self.conn[self.token])

  proc delete*(self:SessionDb, key:string) {.async.} =
    let db = self.conn
    defer: db.close()
    let row = db[self.token]
    if row.hasKey(key):
      row.delete(key)
      db.flush()

  proc destroy*(self:SessionDb) {.async.} =
    self.conn.delete(self.token)
    defer: self.conn.close()


# ========= Session ==================
type Session* = ref object
  db: SessionDb

proc newSession*(token=""):Future[Session] {.async.} =
  # if SESSION_TYPE == "file":
  return Session(db:await newSessionDb(token))

proc db*(self:Session):Future[SessionDb] {.async.} =
  return self.db

proc getToken*(self:Session):Future[string] {.async.} =
  return await self.db.getToken()

proc set*(self:Session, key, value:string) {.async.} =
  await self.db.set(key, value)

proc some*(self:Session, key:string):Future[bool] {.async.} =
  return await self.db.some(key)

proc get*(self:Session, key:string):Future[string] {.async.} =
  return await self.db.get(key)

proc delete*(self:Session, key:string) {.async.} =
  await self.db.delete(key)

proc destroy*(self:Session) {.async.} =
  await self.db.destroy()


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

func toCookieStr*(self:CookieData):string =
  makeCookie(self.name, self.value, self.expire, self.domain, self.path,
              self.secure, self.httpOnly, self.sameSite)


proc newCookieData*(name, value:string, expire:DateTime, sameSite:SameSite=Lax,
      secure=false, httpOnly=true, domain="", path="/"):CookieData =
  let f = initTimeFormat("ddd',' dd MMM yyyy HH:mm:ss 'GMT'")
  let expireStr = format(expire.utc, f)
  when defined(release):
    let secure = true
  CookieData(name:name, value:value,expire:expireStr, sameSite:sameSite,
    secure:secure, httpOnly:httpOnly, domain:domain, path:path)

func newCookieData*(name, value:string, expire="", sameSite: SameSite=Lax,
      secure=false, httpOnly=true, domain = "", path = "/"):CookieData =
  when defined(release):
    let secure = true
  CookieData(name:name, value:value,expire:expire, sameSite:sameSite,
    secure:secure, httpOnly:httpOnly, domain:domain, path:path)

func newCookie*(request:Request):Cookie =
  return Cookie(request:request, cookies:newSeq[CookieData](0))

func cookies(request:Request):Cookie =
  return request.newCookie()

func get*(self:Cookie, name:string):string =
  result = ""
  if not self.request.headers.hasKey("Cookie"):
    return result
  let cookiesStrArr = self.request.headers["Cookie"].split("; ")
  for row in cookiesStrArr:
    let rowArr = row.split("=")
    if rowArr[0] == name:
      result = rowArr[1]
      break

func hasKey*(self:Cookie, name:string):bool =
  if self.get(name).len > 0:
    return true
  else:
    return false

proc add*(self:var Cookie, name, value: string, expire:DateTime,
      sameSite: SameSite=Lax, secure=false, httpOnly=true, domain="",
      path = "/") =
  let f = initTimeFormat("ddd',' dd MMM yyyy HH:mm:ss 'GMT'")
  let expireStr = format(expire.utc, f)
  when defined(release):
    let secure = true
  self.cookies.add(
    newCookieData(name=name, value=value, expire=expireStr, sameSite=sameSite,
      secure=secure, httpOnly=httpOnly, domain=domain, path=path)
  )

proc add*(self:var Cookie, name, value: string, sameSite: SameSite=Lax,
      secure=false, httpOnly=true, domain="", path="/") =
  let expires = timeForward(SESSION_TIME, Minutes)
  let f = initTimeFormat("ddd',' dd MMM yyyy HH:mm:ss 'GMT'")
  let expireStr = format(expires.utc, f)
  when defined(release):
    let secure = true
  self.cookies.add(
    newCookieData(name=name, value=value, expire=expireStr, sameSite=sameSite,
      secure=secure, httpOnly=httpOnly, domain=domain, path=path)
  )

proc updateExpire*(self:var Cookie, name:string, num:int,
                    timeUnit:TimeUnit, path="/") =
  let f = initTimeFormat("ddd',' dd MMM yyyy HH:mm:ss 'GMT'")
  let expireStr = format(timeForward(num, timeUnit).utc, f)
  if self.request.headers.hasKey("Cookie"):
    let cookiesStrArr = self.request.headers["Cookie"].split("; ")

    var
      value:string
      httpOnly:bool
      secure:bool
      domain:string
      path = path
    for i, row in cookiesStrArr:
      let rowArr = row.split("=")
      if rowArr[0] == name:
        value = rowArr[1]
      elif rowArr[0].toLowerAscii == "httponly":
        httpOnly = true
      elif rowArr[0].toLowerAscii == "secure":
        secure = true
      elif rowArr[0].toLowerAscii == "domain":
        domain = rowArr[1]
      elif rowArr[0].toLowerAscii == "path":
        path = rowArr[1]

    self.cookies.add(
      newCookieData(name, value, expire=expireStr, secure=secure,
        httpOnly=httpOnly, domain=domain, path=path)
    )


proc updateExpire*(self:var Cookie, num:int, time:TimeUnit) =
  let f = initTimeFormat("ddd',' dd MMM yyyy HH:mm:ss 'GMT'")
  let expireStr = format(timeForward(num, time).utc, f)
  if self.request.headers.hasKey("Cookie"):
    let cookiesStrArr = self.request.headers["Cookie"].split("; ")
    for row in cookiesStrArr:
      let name = row.split("=")[0]
      let value = row.split("=")[1]
      self.cookies.add(
        newCookieData(name=name, value=value, expire=expireStr)
      )

proc delete*(self:var Cookie, key:string, path="/") =
  self.cookies.add(
    newCookieData(name=key, value="", expire=timeForward(-1, Days), path=path)
  )

# proc destroy*(self:var Cookie, path="/") =
#   if self.request.headers.hasKey("Cookie"):
#     let cookiesStrArr = self.request.headers["Cookie"].split("; ")
#     for row in cookiesStrArr:
#       let name = row.split("=")[0]
#       self.cookies.add(
#         newCookieData(name=name, value="", expire=timeForward(-1, Days), path=path)
#       )


# ========== Auth ====================
type Auth* = ref object
  session*: Session

proc newAuth*(request:Request):Future[Auth] {.async.} =
  ## use in constructor
  var sessionId = newCookie(request).get("session_id")
  if await checkSessionIdValid(sessionId):
    let session = await newSession(sessionId)
    await session.set("last_access", $getTime())
    return Auth(session:session)
  else:
    # return Auth()
    let session = await newSession()
    await session.set("last_access", $getTime())
    return Auth(session:session)

proc newAuth*(sessionId:string):Future[Auth] {.async.} =
  ## use in constructor
  if await checkSessionIdValid(sessionId):
    let session = await newSession(sessionId)
    await session.set("last_access", $getTime())
    return Auth(session:session)
  else:
    return Auth()

# func newAuth():Future[Auth] {.async.} =
#   ## use in constructor
#   let session = await newSession()
#   await session.set("isLogin", "false")
#   await session.set("last_access", $getTime())
#   return Auth(session:session)

# func newAuthIfInvalid*(request:Request):Future[Auth] {.async.} =
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


proc getToken*(self:Auth):Future[string] {.async.} =
  return await self.session.getToken()

proc set*(self:Auth, key, value:string) {.async.} =
  if self.session.isNil:
    self.session = await newSession()
  await self.session.set(key, value)

proc some*(self:Auth, key:string):Future[bool] {.async.} =
  if self.isNil:
    return false
  elif self.session.isNil:
    return false
  else:
    return await self.session.some(key)

proc get*(self:Auth, key:string):Future[string] {.async.} =
  if await self.some(key):
    return await self.session.get(key)
  else:
    return ""

proc delete*(self:Auth, key:string) {.async.} =
  await self.session.delete(key)

proc destroy*(self:Auth) {.async.} =
  await self.session.destroy()

proc login*(self:Auth) {.async.} =
  await self.set("is_login", $true)

proc logout*(self:Auth) {.async.} =
  await self.set("is_login", $false)

proc anonumousCreateSession*(self:Auth, req:Request):Future[bool] {.async.} =
  ## Recreate session because session id from request is invalid
  let sessionId = newCookie(req).get("session_id")
  if not await checkSessionIdValid(sessionId):
    return true
  elif self.session.isNil or not await checkSessionIdValid(await self.getToken):
    self.session = await newSession()
    await self.set("is_login", "false")
    await self.set("last_access", $getTime())
    return true
  else:
    return false

proc isLogin*(self:Auth):Future[bool] {.async.} =
  if await self.some("is_login"):
    return parseBool(await self.session.get("is_login"))
  else:
    return false


# ========== Flash ====================
proc setFlash*(self:Auth, key, value:string) {.async.} =
  let key = "flash_" & key
  await self.set(key, value)

proc hasFlash*(self:Auth, key:string):Future[bool] {.async.} =
  result = false
  let rows = await self.session.db.getRows()
  for k, v in rows.pairs:
    if k.contains("flash_" & key):
      result = true
      break

proc getFlash*(self:Auth):Future[JsonNode] {.async.} =
  result = newJObject()
  let rows = await self.session.db.getRows()
  for key, val in rows.pairs:
    if key.contains("flash_"):
      var newKey = key
      newKey.delete(0, 5)
      result[newKey] = val
      await self.delete(key)


# ========== CsrfToken ====================
type CsrfToken* = ref object
  token:Token


proc newCsrfToken*(token=""):CsrfToken =
  return CsrfToken(token: newToken(token))

func getToken*(self:CsrfToken): string =
  self.token.getToken()

proc csrfToken*(token=""):string =
  var token = newCsrfToken(token).getToken()
  return &"""<input type="hidden" name="csrf_token" value="{token}">"""

proc checkCsrfTimeout*(self:CsrfToken):bool =
  var timestamp:int
  try:
    timestamp = self.token.toTimestamp()
  except:
    raise newException(Exception, "Invalid csrf token")

  if getTime().toUnix > timestamp + SESSION_TIME * 60:
    raise newException(Exception, "Timeout")
  return true
