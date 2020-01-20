import
  httpcore, json, logging, macros, options, os, parsecfg, random, std/sha1,
  strformat, strutils, tables, terminal, times
# 3rd party
import jester/private/utils
import flatdb
# framework
import private

type Login* = ref object
  db*: FlatDb
  isLogin*: bool
  token*: string
  info*: Table[string, string]

const
  SESSION_DB = getEnv("SESSION_DB").string
  IS_SESSION_MEMORY = getEnv("IS_SESSION_MEMORY").string.parseBool

proc initFlatDb(): FlatDb =
  newFlatDb(SESSION_DB, IS_SESSION_MEMORY)


proc genCookie*(name, value: string, expires="",
                    sameSite: SameSite=Lax, secure = false,
                    httpOnly = false, domain = "", path = ""): string =
  ## Creates a cookie which stores ``value`` under ``name``.
  ##
  ## The SameSite argument determines the level of CSRF protection that
  ## you wish to adopt for this cookie. It's set to Lax by default which
  ## should protect you from most vulnerabilities. Note that this is only
  ## supported by some browsers:
  ## https://caniuse.com/#feat=same-site-cookie-attribute
  return makeCookie(name, value, expires, domain, path, secure, httpOnly, sameSite)

proc genCookie*(name, value: string, expires: DateTime,
                    sameSite: SameSite=Lax, secure = false,
                    httpOnly = false, domain = "", path = ""): string =
  ## Creates a cookie which stores ``value`` under ``name``.
  genCookie(name, value,
            format(expires.utc, "ddd',' dd MMM yyyy HH:mm:ss 'GMT'"),
            sameSite, secure, httpOnly, domain, path)

proc getCookie*(request:Request, key:string): string =
  if not request.headers.hasKey("Cookie"):
    return ""
  let cookiesStrArr = request.headers["Cookie"].split(";")
  for row in cookiesStrArr:
    let rowArr = row.split("=")
    if rowArr[0] == key:
      return rowArr[1]

proc setCookie*(r:Response, c:string): Response =
  ## maybe c would be token
  r.header("Set-cookie", c)

proc deleteCookie*(r:Response, key:string): Response =
  var cookie = genCookie(key, "", daysForward(-1))
  r.header("Set-cookie", cookie)

proc checkCsrfToken*(request:Request) =
  if request.reqMethod == HttpPost or
        request.reqMethod == HttpPut or
        request.reqMethod == HttpPatch or
        request.reqMethod == HttpDelete:
    # key not found
    if not request.params.contains("_token"):
      raise newException(Exception, "CSRF verification failed.")
    # check token is valid
    let token = request.params["_token"]
    var db = initFlatDb()
    discard db.load()
    let session = db.queryOne(equal("token", token))
    if isNil(session):
      raise newException(Exception, "CSRF verification failed.")
    # check timeout
    let loginAt = session["login_at"].getStr.parseInt
    if getTime().toUnix() > loginAt + SESSION_TIME:
      # delete token from session
      let id = session["_id"].getStr
      db.delete(id)
      raise newException(Exception, "Session Timeout.")
    # update login time
    session["login_at"] = %($(getTime().toUnix()))
    # delete onetime session
    if not session.hasKey("uid"):
      let id = session["_id"].getStr
      db.delete(id)
    db.flush()

proc checkCookieToken*(request:Request) =
  if request.reqMethod == HttpGet:
    let token = request.getCookie("token")
    if token.len > 0:
      var db = initFlatDb()
      discard db.load()
      let session = db.queryOne(equal("token", token))
      if isNil(session):
        raise newException(Exception, "CSRF verification failed.")
      # check timeout
      let loginAt = session["login_at"].getStr.parseInt
      if getTime().toUnix() > loginAt + SESSION_TIME:
        # delete token from session
        let id = session["_id"].getStr
        db.delete(id)
        raise newException(Exception, "Session Timeout.")
      # uppdate last login
      session["login_at"] = %($(getTime().toUnix()))
      db.flush()

proc rundStr():string =
  randomize()
  for _ in .. 50:
    add(result, char(rand(int('A')..int('z'))))

proc sessionStart*(uid:int):string =
  randomize()
  let token = rundStr().secureHash()
  # insert db
  var db = initFlatDb()
  discard db.load()
  db.append(%*{
    "token": $token, "login_at": $(getTime().toUnix()), "uid": uid
  })
  return $token

proc sessionDestroy*(login:Login) =
  var db = initFlatDb()
  discard db.load()
  let session = db.queryOne(equal("token", login.token))
  let id = session["_id"].getStr
  db.delete(id)

proc newSession*(): string =
  randomize()
  let token = rundStr().secureHash()
  var db = initFlatDb()
  discard db.load()
  db.append(%*{
    "token": $token, "login_at": $(getTime().toUnix())
  })
  return $token

proc addSession*(token:string, key:string, val:string) =
  var db = initFlatDb()
  discard db.load()
  let session = db.queryOne(equal("token", token))
  if isNil(session):
    raise newException(Error403, "CSRF verification failed.")
  # check timeout
  let generatedAt = session["login_at"].getStr.parseInt
  if getTime().toUnix() > generatedAt + SESSION_TIME:
    raise newException(Error403, "Session Timeout.")
  # add
  session[key] = %val
  db.flush()

proc removeSession*(token:string) =
  var db = initFlatDb()
  discard db.load()
  let session = db.queryOne(equal("token", token))
  let id = session["_id"].getStr
  db.delete id

proc getSession*(request:Request, key:string): string =
  let token = request.getCookie("token")
  var db = initFlatDb()
  discard db.load()
  let session = db.queryOne(equal("token", token))
  result = ""
  if session.hasKey(key):
    result = session[key].getStr


proc csrfToken*(login:Login):string =
  # insert db
  if login.isLogin:
    var db = initFlatDb()
    discard db.load()
    let session = db.queryOne(equal("token", login.token))
    session["login_at"] = %($(getTime().toUnix()))
    return &"""<input type="hidden" name="_token" value="{login.token}">"""
  else:
    randomize()
    let token = rundStr().secureHash()
    var db = initFlatDb()
    discard db.load()
    db.append(%*{
      "token": $token, "login_at": $(getTime().toUnix())
    })
    return &"""<input type="hidden" name="_token" value="{token}">"""

proc initLogin*(request:Request): Login =
  let token = request.getCookie("token")
  var db = initFlatDb()
  discard db.load()
  var info = initTable[string, string]()
  let session = db.queryOne(equal("token", token))
  if session == nil:
    return Login(isLogin: false)
  for key, val in session.pairs:
    if key.contains("login_"):
      info[key] = val.get
  return Login(
    isLogin: true,
    info: info,
    token: token
  )

