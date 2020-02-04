import
  httpcore, json, logging, macros, options, os, parsecfg, std/sha1,
  strformat, strutils, tables, terminal, times
# framework
import base
# 3rd party
import jester except redirect, setCookie, setHeader, resp
import bcrypt, flatdb, templates

export base
export jester except redirect, setCookie, setHeader, resp
export bcrypt, flatdb, templates

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


# ==================== response ================================================

template setHeader(headers: var Option[RawHeaders], key, value: string): typed =
  ## Customized for jester
  bind isNone
  if isNone(headers):
    headers = some(@({key: value}))
  else:
    block outer:
      # Overwrite key if it exists.
      var h = headers.get()
      if key != "Set-cookie": # multiple cookies should be allowed
        for i in 0 ..< h.len:
          if h[i][0] == key:
            h[i][1] = value
            headers = some(h)
            break outer

      # Add key if it doesn't exist.
      headers = some(h & @({key: value}))

template resp*(code: HttpCode,
               headers: openarray[tuple[key, val: string]],
               content: string): typed =
  ## Sets ``(code, headers, content)`` as the response.
  bind TCActionSend
  result = (TCActionSend, code, none[RawHeaders](), content, true)
  for header in headers:
    setHeader(result[2], header[0], header[1])
  break route


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

proc joinHeader(headers:openArray[Headers]): Headers =
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
  var newHeader: Headers
  var tmp = result.toTable
  for header in headers:
    let headerTable = header.toOrderedTable
    for key, value in headerTable.pairs:
      if tmp.hasKey(key):
        tmp[key] = [tmp[key], headerTable[key]].join(", ")
      else:
        tmp[key] = headerTable[key]
  for key, val in tmp.pairs:
    newHeader.add(
      (key:key, val:val)
    )
  return newHeader


template route*(respinseArg:Response,
                headersArg:openArray[Headers]) =
  block:
    let response = respinseArg
    var headersMiddleware = @headersArg
    var newHeaders: Headers
    headersMiddleware.add(response.headers) # headerMiddleware + headerController
    newHeaders = joinHeader(headersMiddleware)
    case response.responseType:
    of String:
      newHeaders.add(("Content-Type", "text/html;charset=utf-8"))
    of Json:
      newHeaders.add(("Content-Type", "application/json"))
      response.bodyString = $(response.bodyJson)
    of Redirect:
      logger($response.status & &"  {request.ip}  {request.reqMethod}  {request.path}")
      newHeaders.add(("Location", response.url))
      resp response.status, newHeaders, ""

    if response.status == Http200:
      logger($response.status & &"  {request.ip}  {request.reqMethod}  {request.path}")
      logger($newHeaders)
    elif response.status.is4xx() or response.status.is5xx():
      echoErrorMsg($response.status & &"  {request.ip}  {request.reqMethod}  {request.path}")
      echoErrorMsg($newHeaders)
    resp response.status, newHeaders, response.bodyString


proc response*(arg:ResponseData):Response =
  if not arg[4]: raise newException(Error404, "")
  # ↓ TODO DELETE after pull request mergeed https://github.com/dom96/jester/pull/234
  # var newHeader:Headers
  # for header in arg[2].get(@[("", "")]):
  #   newHeader.add((header.key , header.val))
  # ↑
  return Response(
    status: arg[1],
    # headers: newHeader,
    headers: arg[2].get, # TODO after pull request mergeed https://github.com/dom96/jester/pull/234
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


import errorPage

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
  if status.is4xx() or status.is5xx():
    echoErrorMsg($request.params)
    echoErrorMsg($status & &"  {request.reqMethod}  {request.ip}  {request.path}  {exception.msg}")
    if pagePath == "":
      route(render(errorPage(status, exception.msg)))
    else:
      route(render(html(pagePath)))
  else:
    route(errorRedirect(exception.msg))


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
proc header*(response:Response, key:string, value:string):Response =
  block:
    var response = response
    var index = 0
    var preValue = ""
    for i, row in response.headers:
      if row.key == key:
        index = i
        preValue = row.val
        break

    if preValue.len == 0:
      response.headers.add(
        (key, value)
      )
    else:
      response.headers[index] = (key, preValue & ", " & value)
    return response

proc header*(response:Response, key:string, valuesArg:openArray[string]):Response =
  block:
    var response = response
    var value = ""
    for i, v in valuesArg:
      if i > 0:
        value.add(", ")
      value.add(v)
    response.headers.add((key, value))
    return response

# load html
# proc html*(r_path:string):string =
#   ## arg r_path is relative path from /resources/
#   block:
#     let path = getCurrentDir() & "/resources/" & r_path
#     let f = open(path, fmRead)
#     result = $(f.readAll)
#     defer: f.close()

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
