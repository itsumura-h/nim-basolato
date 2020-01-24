import
  httpcore, json, logging, macros, options, os, parsecfg, std/sha1,
  strformat, strutils, tables, terminal, times
# framework
import base
# 3rd party
import jester except redirect, setCookie
import bcrypt, flatdb, templates

export base
export jester except redirect, setCookie
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
