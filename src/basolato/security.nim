import httpcore, json, tables, strutils, times, random, strformat, tables
# framework
import base
# 3rd party
import flatdb, nimAES
from jester import daysForward
import jester/request
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

proc checkTokenValid(db:FlatDb, token:string) =
  try:
    discard db[token]
  except:
    raise newException(Exception, "Invalid session id")

proc newSessionDb*(token=""):SessionDb =
  let db = newFlatDb(SESSION_DB_PATH, IS_SESSION_MEMORY)
  discard db.load()
  if token.len > 0:
    var token = token.decryptCtr()
    checkTokenValid(db, token)
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

proc minutesForward*(minutes:int): DateTime =
  return getTime().utc + initTimeInterval(minutes = minutes)

proc toCookieStr*(this:CookieData):string =
  makeCookie(this.name, this.value,this.expire,this.domain, this.path,
              this.secure,this.httpOnly, this.sameSite)

proc newCookieData*(name, value:string, expire:DateTime, sameSite: SameSite=Lax,
      secure = false, httpOnly = false, domain = "", path = "/"):CookieData =
  let f = initTimeFormat("ddd',' dd MMM yyyy HH:mm:ss 'GMT'")
  let expireStr = format(expire.utc, f)
  CookieData(name:name, value:value,expire:expireStr, sameSite:sameSite,
    secure:secure, httpOnly:httpOnly, domain:domain, path:path)

proc newCookieData*(name, value:string, expire="", sameSite: SameSite=Lax,
      secure = false, httpOnly = false, domain = "", path = "/"):CookieData =
  CookieData(name:name, value:value,expire:expire, sameSite:sameSite,
    secure:secure, httpOnly:httpOnly, domain:domain, path:path)

proc newCookie*(request:Request):Cookie =
  return Cookie(request:request, cookies:newSeq[CookieData](0))

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

proc set*(this:Cookie, name, value: string, expire:DateTime,
      sameSite: SameSite=Lax, secure = false, httpOnly = false, domain = "",
      path = "/"):Cookie =
  let f = initTimeFormat("ddd',' dd MMM yyyy HH:mm:ss 'GMT'")
  let expireStr = format(expire.utc, f)
  this.cookies.add(
    CookieData(name:name, value:value, expire:expireStr, sameSite:sameSite,
      secure:secure, httpOnly:httpOnly, domain:domain, path:path)
  )

proc set*(this:Cookie, name, value: string, sameSite: SameSite=Lax,
      secure = false, httpOnly = false, domain = "", path = "/"):Cookie =
  let expires = minutesForward(CSRF_TIME)
  let f = initTimeFormat("ddd',' dd MMM yyyy HH:mm:ss 'GMT'")
  let expireStr = format(expires.utc, f)
  this.cookies.add(
    CookieData(name:name, value:value, expire:expireStr, sameSite:sameSite,
      secure:secure, httpOnly:httpOnly, domain:domain, path:path)
  )
  return this

proc updateExpire*(this:Cookie, name:string, days:int, path="/"):Cookie =
  let f = initTimeFormat("ddd',' dd MMM yyyy HH:mm:ss 'GMT'")
  let expireStr = format(daysForward(days).utc, f)
  if this.request.headers.hasKey("Cookie"):
    let cookiesStrArr = this.request.headers["Cookie"].split("; ")
    for i, row in cookiesStrArr:
      let rowArr = row.split("=")
      if rowArr[0] == name:
        this.cookies.add(newCookieData(rowArr[0], rowArr[1], expire=expireStr))
        break
  return this

proc delete*(this:Cookie, key:string, path="/"):Cookie =
  this.cookies.add(
    newCookieData(name=key, value="", expire=daysForward(-1), path=path)
  )
  return this

proc destroy*(this:Cookie, path="/"):Cookie =
  if this.request.headers.hasKey("Cookie"):
    let cookiesStrArr = this.request.headers["Cookie"].split("; ")
    for row in cookiesStrArr:
      let name = row.split("=")[0]
      this.cookies.add(
        newCookieData(name=name, value="", expire=daysForward(-1), path=path)
      )
  return this


# ========== Auth ====================
type Auth* = ref object
  isLogin*:bool
  session*:Session

proc newAuth*(request:Request):Auth =
  ## use in constructor
  var sessionId = newCookie(request).get("session_id")
  if sessionId.len > 0:
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

proc getToken*(this:Auth):string =
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

proc delete*(this:Auth, key:string):AUth =
  discard this.session.delete(key)
  return this

proc destroy*(this:Auth) =
  this.session.destroy()


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


proc newCsrfToken*(token:string):CsrfToken =
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
