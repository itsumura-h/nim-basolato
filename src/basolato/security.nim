import httpcore, json, tables, strutils, times, random
# framework
import base, private, response
# 3rd party
import flatdb, nimAES
import jester/private/utils


# ========= Encrypt ==================
proc randStr*(n:openArray[int]):string =
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
  var input = randStr([16]) & input
  input.commonCtr().toHex()

proc decryptCtr*(input:string):string =
  var input = input.parseHexStr()
  var output = input.commonCtr()
  return output[16..high(output)]


# ========= Flat DB ==================
type SessionDb = ref object
  conn: FlatDb
  token: string

proc newSessionDb*(token=""):SessionDb =
  let db = newFlatDb(SESSION_DB_PATH, IS_SESSION_MEMORY)
  discard db.load()
  if token.len > 0:
    return SessionDb(conn: db, token:token)
  else:
    let token = db.append(newJObject())
    return SessionDb(conn: db, token:token)

proc getToken*(this:SessionDb): string =
  this.token.encryptCtr()

proc set*(this:SessionDb, key, value:string):SessionDb =
  let db = this.conn
  db[this.token][key] = %value
  db.flush()
  return this

proc get*(this:SessionDb, key:string): string =
  let db = this.conn
  return db[this.token].getOrDefault(key).getStr("")

proc delete*(this:SessionDb, key:string):SessionDb =
  let db = this.conn
  let row = db[this.token]
  if row.hasKey(key):
    row.delete(key)
    db.flush()
  return this

proc destroy*(this:SessionDb) =
  this.conn.delete(this.token)


# ========= Session ==================
type 
  SessionType* = enum
    File
    Redis

  Session* = ref object
    db: SessionDb

proc newSession*(token="", typ:SessionType=File):Session =
  if typ == File:
    return Session(db:newSessionDb(token))

proc db*(this:Session):SessionDb =
  this.db

proc getToken*(this:Session):string =
  this.db.getToken()

proc set*(this:Session, key, value:string):Session =
  discard this.db.set(key, value)
  return this

proc get*(this:Session, key:string):string =
  this.db.get(key)

proc delete*(this:Session, key:string): Session =
  discard this.db.delete(key)
  return this

proc destroy*(this:Session) =
  this.db.destroy()

# ========== Cookie ====================
type Cookie* = ref object
  request:Request
  cookies*:seq[string]

proc createCookie*(name, value: string, expires="",
                    sameSite: SameSite=Lax, secure = false,
                    httpOnly = false, domain = "", path = "/"): string =
  ## https://github.com/dom96/jester/blob/4c3965259891de174c059dfc9165dfe8d6ddc600/jester.nim#L716
  return makeCookie(name, value, expires, domain, path, secure, httpOnly, sameSite)

proc createCookie*(name, value: string, expires:DateTime,
                    sameSite: SameSite=Lax, secure = false,
                    httpOnly = false, domain = "", path = "/"): string =
  let f = initTimeFormat("ddd',' dd MMM yyyy HH:mm:ss 'GMT'")
  let expireStr = format(expires.utc, f)
  createCookie(name, value, expireStr, sameSite, secure, httpOnly, domain, path)

proc minutesForward*(minutes:int): DateTime =
  return getTime().utc + initTimeInterval(minutes = minutes)

proc newCookie*(request:Request):Cookie =
  return Cookie(request:request)

proc set*(this:Cookie, name, value: string, expires:DateTime,
      sameSite: SameSite=Lax, secure = false, httpOnly = false, domain = "", path = "/"):Cookie =
  let f = initTimeFormat("ddd',' dd MMM yyyy HH:mm:ss 'GMT'")
  let expireStr = format(expires.utc, f)
  let cookie = createCookie(name, value, expireStr, sameSite, secure, httpOnly, domain, path)
  this.cookies.add(cookie)
  return this

proc set*(this:Cookie, name, value: string, sameSite: SameSite=Lax,
      secure = false, httpOnly = false, domain = "", path = "/"):Cookie =
  let expires = minutesForward(CSRF_TIME)
  let f = initTimeFormat("ddd',' dd MMM yyyy HH:mm:ss 'GMT'")
  let expireStr = format(expires.utc, f)
  let cookie = createCookie(name, value, expireStr, sameSite, secure, httpOnly, domain, path)
  this.cookies.add(cookie)
  return this
      

proc getCookie*(request:Request, key:string): string =
  result = ""
  if not request.headers.hasKey("Cookie"):
    return result
  let cookiesStrArr = request.headers["Cookie"].split("; ")
  for row in cookiesStrArr:
    let rowArr = row.split("=")
    if rowArr[0] == key:
      result = rowArr[1]

proc setCookie*(response:Response, cookie:Cookie):Response =
  for row in cookie.cookies:
    response.headers.add(("Set-cookie", row))
  # echo response.headers
  return response  

proc setCookie*(response:Response, content:string): Response =
  # resonse.header("Set-cookie", content)
  response.headers.add(
    ("Set-cookie", content)
  )
  return response

proc updateCookieExpire*(response:Response, request:Request, key:string, days:int, path="/"): Response =
  let f = initTimeFormat("ddd',' dd MMM yyyy HH:mm:ss 'GMT'")
  let expireStr = format(daysForward(days).utc, f)
  let content = createCookie(key, request.getCookie(key), expireStr, Lax, false, false, "", path)
  response.header("Set-cookie", content)

proc deleteCookie*(response:Response, key:string, path="/"): Response =
  let cookie = createCookie(key, "", daysForward(-1), path=path)
  response.header("Set-cookie", cookie)

proc deleteCookies*(response:Response, request:Request, path="/"): Response =
  block:
    var response = response
    for row in request.headers["Cookie"].split("; "):
      let rowArr = row.split("=")
      let cookie = createCookie(rowArr[0], "", daysForward(-1), path=path)
      response = response.setCookie(cookie)
    return response

# ========== Auth ====================
type
  Auth* = ref object
    isLogin*:bool
    session*:Session

proc checkSessionIdValid*(sessionId:string) =
  var sessionId = sessionId.decryptCtr()
  if sessionId.len != 24:
    raise newException(Exception, "Invalid session_id")

proc newAuth*(request:Request):Auth =
  ## use in constructor
  var sessionId = request.getCookie("session_id")
  if sessionId.len > 0:
    sessionId = sessionId.decryptCtr()
    return Auth(
      isLogin: true,
      session:newSession(sessionId)
    )
  else:
    return Auth(isLogin:false)

proc newAuth*():Auth =
  ## use in action method
  return Auth(
    isLogin: true,
    session:newSession()
  )

proc isLogin*(this:Auth):bool =
  this.isLogin

proc getId*(this:Auth):string =
  this.session.getToken()

proc get*(this:Auth, key:string):string =
  if this.isLogin:
    return this.session.get(key)
  else:
    return ""

proc set*(this:Auth, key, value:string):Auth =
  if this.isLogin:
    discard this.session.set(key, value)
  return this

proc destroy*(this:Auth) =
  this.session.destroy()