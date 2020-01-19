import
  httpcore, json, logging, macros, options, os, parsecfg, random, std/sha1,
  strformat, strutils, tables, terminal, times
# 3rd party
import jester except redirect, setCookie
import jester/private/utils
import bcrypt, flatdb, templates

export jester except redirect, setCookie
export bcrypt, flatdb, templates

const
  basolatoVersion* = "v0.1.0"
  IS_DISPLAY = getEnv("LOG_IS_DISPLAY").string.parseBool
  IS_FILE = getEnv("LOG_IS_FILE").string.parseBool
  LOG_DIR = getEnv("LOG_DIR").string
  SESSION_TIME = getEnv("SESSION_TIME").string.parseInt

type
  Response* = ref object
    status*:HttpCode
    body*: string
    bodyString*: string
    bodyJson*: JsonNode
    responseType*: ResponseType
    headers*: seq[tuple[key, value:string]]
    # headers*: seq[tuple[key, val:string]] # TODO after pull request mergeed https://github.com/dom96/jester/pull/234
    url*: string
    match*: bool

  ResponseType* = enum
    String
    Json
    Redirect

  Login* = ref object
    isLogin*: bool
    token*: string
    info*: Table[string, string]
  
const errorStatusArray* = [505, 504, 503, 502, 501, 500, 451, 431, 429, 428, 426,
  422, 421, 418, 417, 416, 415, 414, 413, 412, 411, 410, 409, 408, 407, 406,
  405, 404, 403, 401, 400]

macro createHttpException():untyped =
  var strBody = """type
"""
  for num in errorStatusArray:
    strBody.add(fmt"""  Error{num}* = object of Exception
""")
  parseStmt(strBody)
createHttpException


# ==================== logger =================================================

proc logger*(output: any, args:varargs[string]) =
  if IS_DISPLAY:
    let logger = newConsoleLogger()
    logger.log(lvlInfo, $output & $args)
  if IS_FILE:
    let path = LOG_DIR & "/log.log"
    createDir(parentDir(path))
    let logger = newRollingFileLogger(path, mode=fmAppend, fmtStr=verboseFmtStr)
    logger.log(lvlInfo, $output & $args)
    flushFile(logger.file)


proc echoErrorMsg*(msg:string) =
  # console log
  if IS_DISPLAY:
    styledWriteLine(stdout, fgRed, bgDefault, msg, resetStyle)
  # file log
  if IS_FILE:
    let path = LOG_DIR & "/error.log"
    createDir(parentDir(path))
    let logger = newRollingFileLogger(path, mode=fmAppend, fmtStr=verboseFmtStr)
    logger.log(lvlError, msg)
    flushFile(logger.file)


# ==================== routing ================================================

template route*(rArg: Response) =
  block:
    let r = rArg
    var newHeaders = r.headers
    case r.responseType:
    of String:
      newHeaders.add(("Content-Type", "text/html;charset=utf-8"))
    of Json:
      newHeaders.add(("Content-Type", "application/json"))
      r.bodyString = $(r.bodyJson)
    of Redirect:
      logger($r.status & &"  {request.ip}  {request.reqMethod}  {request.path}")
      newHeaders.add(("Location", r.url))
      resp r.status, newHeaders, ""

    if r.status == Http200:
      logger($r.status & &"  {request.ip}  {request.reqMethod}  {request.path}")
      logger($newHeaders)
    elif r.status.is4xx() or r.status.is5xx():
      echoErrorMsg($request.params)
      echoErrorMsg($r.status & &"  {request.ip}  {request.reqMethod}  {request.path}")
      echoErrorMsg($newHeaders)
    resp r.status, newHeaders, r.bodyString

# TODO after pull request mergeed https://github.com/dom96/jester/pull/234
# proc joinHeader(headers:openArray[seq[tuple]]): seq[tuple[key,val:string]] =
proc joinHeader(headers:openArray[seq[tuple]]): seq[tuple[key,value:string]] =
  ## join seq and children tuple if each headers have same key in child tuple
  ##
  ## .. code-block:: nim
  ##    let t1 = @[("key1", "val1"),("key2", "val2")]
  ##    let t2 = @[("key1", "val1++"),("key3", "val3")]
  ##    let t3 = joinHeader([t1, t2])
  ##
  ##    echo t3
  ##    >> @[
  ##      ("key1", "val1, val1++"),
  ##      ("key2", "val2"),
  ##      ("key3", "val3"),
  ##    ]
  ##
  var tmp:seq[tuple[key,value:string]]
  var tmp_tbl = tmp.toOrderedTable
  for header in headers:
    let header_tbl = header.toOrderedTable
    for key, value in header_tbl.pairs:
      if tmp_tbl.hasKey(key):
        tmp_tbl[key] = [tmp_tbl[key], header_tbl[key]].join(", ")
      else:
        tmp_tbl[key] = header_tbl[key]
  var result: seq[tuple[key,value:string]]
  for key, val in tmp_tbl.pairs:
    result.add((key:key, value:val))
  return result


template route*(rArg:Response,
                headers:openArray[seq[tuple]]) =
  block:
    let r = rArg
    # TODO after pull request mergeed https://github.com/dom96/jester/pull/234
    # var newHeaders: seq[tuple[key,val:string]]
    var newHeaders: seq[tuple[key,value:string]]
    newHeaders = joinHeader(headers)
    case r.responseType:
    of String:
      newHeaders.add(("Content-Type", "text/html;charset=utf-8"))
    of Json:
      newHeaders.add(("Content-Type", "application/json"))
      r.bodyString = $(r.bodyJson)
    of Redirect:
      logger($r.status & &"  {request.ip}  {request.reqMethod}  {request.path}")
      newHeaders.add(("Location", r.url))
      resp r.status, newHeaders, ""

    if r.status == Http200:
      logger($r.status & &"  {request.ip}  {request.reqMethod}  {request.path}")
      logger($newHeaders)
    elif r.status.is4xx() or r.status.is5xx():
      echoErrorMsg($request.params)
      echoErrorMsg($r.status & &"  {request.ip}  {request.reqMethod}  {request.path}")
      echoErrorMsg($newHeaders)
    resp r.status, newHeaders, r.bodyString


proc response*(arg:ResponseData):Response =
  if not arg[4]: raise newException(Error404, "")
  # ↓ TODO DELETE after pull request mergeed https://github.com/dom96/jester/pull/234
  var newHeader:seq[tuple[key, value:string]]
  for header in arg[2].get(@[("", "")]):
    newHeader.add((key:header.key , value:header.val))
  # ↑
  return Response(
    status: arg[1],
    headers: newHeader,
    # headers: arg[2].get, # TODO after pull request mergeed https://github.com/dom96/jester/pull/234
    body: arg[3],
    match: arg[4]
  )
  
proc response*(status:HttpCode, body:string): Response =
  return Response(
    status:status,
    bodyString: body,
    responseType: String
  )

template middleware*(procs:varargs[Response]) =
  for p in procs:
    if p == nil:
      # echo getCurrentExceptionMsg()
      discard
    else:
      route(p)
      break

macro dynamicImportErrorPage() =
  let path = getProjectPath()
  parseStmt(fmt"""
import {path}/resources/framework/error
""")
dynamicImportErrorPage

template http404Route*(pagePath="") =
  if not request.path.contains("favicon"):
    echoErrorMsg(&"{$Http404}  {request.ip}  {request.path}")
  if pagePath == "":
    route(render(errorPage(Http404, "route not match")))
  else:
    route(render(html(pagePath)))

macro createHttpCodeError():untyped =
  var strBody = ""
  for num in errorStatusArray:
    strBody.add(fmt"""
of "Error{num.repr}":
  return Http{num.repr}
""")
  return parseStmt(fmt"""
case $exception.name
{strBody}
else:
  return Http500
""")

proc checkHttpCode(exception:ref Exception):HttpCode =
  ## Generated by macro createHttpCodeError
  ## List is httpCodeArray
  ## .. code-block:: nim
  ##   case $exception.name
  ##   of Error505:
  ##     return Http505
  ##   of Error504:
  ##     return Http504
  ##   of Error503:
  ##     return Http503
  ##   .
  ##   .
  createHttpCodeError

template exceptionRoute*(pagePath="") =
  defer: GCunref exception
  let status = checkHttpCode(exception)
  echoErrorMsg($request.params)
  echoErrorMsg($status & &"  {request.reqMethod}  {request.ip}  {request.path}  {exception.msg}")
  if pagePath == "":
    route(render(errorPage(status, exception.msg)))
  else:
    route(render(html(pagePath)))


# ==================== controller =============================================

# String
proc render*(body:string):Response =
  return Response(status:Http200, bodyString:body, responseType:String)

proc render*(status:HttpCode, body:string):Response =
  return Response(status:status, bodyString:body, responseType:String)


# Json
proc render*(body:JsonNode):Response =
  return Response(status:Http200, bodyJson:body, responseType:Json)

proc render*(status:HttpCode, body:JsonNode):Response =
  return Response(status:status, bodyJson:body, responseType:Json)


proc redirect*(url:string) : Response =
  return Response(
    status:Http303, url:url, responseType: Redirect
  )

proc errorRedirect*(url:string): Response =
  return Response(
    status:Http302, url:url, responseType: Redirect
  )
  

# with header
proc header*(r:Response, key:string, value:string):Response =
  var response = r
  response.headers.add(
    (key, value)
  )
  return response

proc header*(r:Response, key:string, valuesArg:openArray[string]):Response =
  var response = r
  
  var value = ""
  for i, v in valuesArg:
    if i > 0:
      value.add(", ")
    value.add(v)

  response.headers.add((key, value))
  return response

proc setCookie*(r:Response, c:string): Response =
  r.header("Set-cookie", c)

# load html
proc html*(r_path:string):string =
  ## arg r_path is relative path from /resources/
  block:
    let path = getCurrentDir() & "/resources/" & r_path
    let f = open(path, fmRead)
    result = $(f.readAll)
    defer: f.close()

# ==================== view ===================================================

proc get*(val:JsonNode):string =
  case val.kind
  of JString:
    return val.getStr
  of JInt:
    return $(val.getInt)
  of JFloat:
    return $(val.getFloat)
  of JBool:
    return $(val.getBool)
  of JNull:
    return ""
  else:
    raise newException(JsonKindError, "val is array")

# ==================== session ================================================

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
    let generatedAt = session["generated_at"].getStr.parseInt
    if getTime().toUnix() > generatedAt + SESSION_TIME:
      raise newException(Error403, "Session Timeout.")
    # delete token from session
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
    "token": $token, "generated_at": $(getTime().toUnix()), "uid": uid
  })
  return $token

proc newSession*(): string =
  randomize()
  let token = rundStr().secureHash()
  var db = newFlatDb("session.db", false)
  discard db.load()
  db.append(%*{
    "token": $token, "generated_at": $(getTime().toUnix())
  })
  return $token

proc addSession*(token:string, key:string, val:string) =
  var db = newFlatDb("session.db", false)
  discard db.load()
  let session = db.queryOne(equal("token", token))
  if isNil(session):
    raise newException(Error403, "CSRF verification failed.")
  # check timeout
  let generatedAt = session["generated_at"].getStr.parseInt
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
  randomize()
  let token = rundStr().secureHash()
  # insert db
  if login.isLogin:
    let session = getSession(login.token)
    session["generated_at"] = $(getTime().toUnix())
    return &"""<input type="hidden" name="_token" value="{login.token}">"""
  else:
    let session = newSession()
  # var db = newFlatDb("session.db", false)
  # discard db.load()
  # db.append(%*{
  #   "token": $token, "generated_at": $(getTime().toUnix())
  # })
  return &"""<input type="hidden" name="_token" value="{token}">"""

proc initLogin*(request:Request): Login =
  let token = request.getCookie("token")
  echo token
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

