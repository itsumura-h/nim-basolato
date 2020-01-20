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
      raise newException(Error403, "CSRF verification failed.")
    # check token is valid
    let token = request.params["_token"]
    var db = newFlatDb("session.db", false)
    discard db.load()
    let session = db.queryOne(equal("token", token))
    if isNil(session):
      raise newException(Error403, "CSRF verification failed.")
    # check timeout
    let generatedAt = session["login_at"].getStr.parseInt
    if getTime().toUnix() > generatedAt + SESSION_TIME:
      # delete token from session
      let id = session["_id"].getStr
      db.delete(id)
      raise newException(Error403, "Session Timeout.")
    # update login time
    session["login_at"] = %($(getTime().toUnix()))
    # delete onetime session
    if not session.hasKey("uid"):
      let id = session["_id"].getStr
      db.delete(id)

proc rundStr():string =
  randomize()
  for _ in .. 50:
    add(result, char(rand(int('A')..int('z'))))

proc sessionStart*(uid:int):string =
  randomize()
  let token = rundStr().secureHash()
  # insert db
  var db = newFlatDb("session.db", false)
  discard db.load()
  db.append(%*{
    "token": $token, "login_at": $(getTime().toUnix()), "uid": uid
  })
  return $token

proc sessionDestroy*(login:Login) =
  var db = newFlatDb("session.db", false)
  discard db.load()
  let session = db.queryOne(equal("token", login.token))
  let id = session["_id"].getStr
  db.delete(id)

proc newSession*(): string =
  randomize()
  let token = rundStr().secureHash()
  var db = newFlatDb("session.db", false)
  discard db.load()
  db.append(%*{
    "token": $token, "login_at": $(getTime().toUnix())
  })
  return $token

proc addSession*(token:string, key:string, val:string) =
  var db = newFlatDb("session.db", false)
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
  var db = newFlatDb("session.db", false)
  discard db.load()
  let session = db.queryOne(equal("token", token))
  let id = session["_id"].getStr
  db.delete id

proc getCookie*(request:Request, key:string): string =
  if not request.headers.hasKey("Cookie"):
    return ""
  let cookiesStrArr = request.headers["Cookie"].split(";")
  for row in cookiesStrArr:
    let rowArr = row.split("=")
    if rowArr[0] == key:
      return rowArr[1]


proc getSession*(request:Request, key:string): string =
  let token = request.getCookie("token")
  var db = newFlatDb("session.db", false)
  discard db.load()
  let session = db.queryOne(equal("token", token))
  result = ""
  if session.hasKey(key):
    result = session[key].getStr


proc csrfToken*(login:Login):string =
  # insert db
  if login.isLogin:
    echo "ログインしてる"
    var db = newFlatDb("session.db", false)
    discard db.load()
    let session = db.queryOne(equal("token", login.token))
    echo session
    session["login_at"] = %($(getTime().toUnix()))
    return &"""<input type="hidden" name="_token" value="{login.token}">"""
  else:
    echo "ログインしてない"
    randomize()
    let token = rundStr().secureHash()
    var db = newFlatDb("session.db", false)
    discard db.load()
    db.append(%*{
      "token": $token, "login_at": $(getTime().toUnix())
    })
    return &"""<input type="hidden" name="_token" value="{token}">"""

proc initLogin*(request:Request): Login =
  let token = request.getCookie("token")
  var db = newFlatDb("session.db", false)
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

