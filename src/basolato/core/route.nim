import
  asynchttpserver, asyncdispatch, json, strformat, macros, strutils, os,
  asyncfile, mimetypes, re, tables, times
from osproc import countProcessors
import baseEnv, request, response, header, logger, error_page, resources/ddPage,
  security/cookie, security/client
export request, header


type Route* = ref object
  httpMethod*:HttpMethod
  path*:string
  action*:proc(r:Request, p:Params):Future[Response]

type MiddlewareRoute* = ref object
  httpMethods*:seq[HttpMethod]
  path*:Regex
  action*:proc(r:Request, p:Params):Future[Response]


proc params*(request:Request, route:Route):Params =
  let url = request.path
  let path = route.path
  let params = newParams()
  for k, v in getUrlParams(url, path).pairs:
    params[k] = v
  for k, v in getQueryParams(request).pairs:
    params[k] = v

  if request.headers.hasKey("content-type") and request.headers["content-type"].split(";")[0] == "application/json":
    for k, v in getJsonParams(request).pairs:
      params[k] = v
  else:
    for k, v in getRequestParams(request).pairs:
      params[k] = v
  return params

proc params*(request:Request, middleware:MiddlewareRoute):Params =
  let url = request.path
  let path = middleware.path
  let params = newParams()
  # for k, v in getUrlParams(url, path).data.pairs:
  #   params[k] = v
  for k, v in getQueryParams(request).pairs:
    params[k] = v
  for k, v in getRequestParams(request).pairs:
    params[k] = v
  return params

type Routes* = ref object
  withParams: seq[Route]
  withoutParams: OrderedTable[string, Route]
  middlewares: seq[MiddlewareRoute]

func newRoutes*():Routes =
  return Routes()

func newRoute(httpMethod:HttpMethod, path:string, action:proc(r:Request, p:Params):Future[Response]):Route =
  return Route(
    httpMethod:httpMethod,
    path:path,
    action:action
  )

func add*(self:var Routes, httpMethod:HttpMethod, path:string, action:proc(r:Request, p:Params):Future[Response]) =
  let route = newRoute(httpMethod, path, action)
  if path.contains("{"):
    self.withParams.add(route)
  else:
    self.withoutParams[ $httpMethod & ":" & path ] = route
    if not [HttpGet, HttpHead, HttpPost].contains(httpMethod):
      self.withoutParams[ $(HttpOptions) & ":" & path ] = route

func middleware*(
  self:var Routes,
  path:Regex,
  action:proc(r:Request, p:Params):Future[Response]
) =
  self.middlewares.add(
    MiddlewareRoute(
      httpMethods: newSeq[HttpMethod](),
      path: path,
      action: action
    )
  )

func middleware*(
  self:var Routes,
  httpMethods:seq[HttpMethod],
  path:Regex,
  action:proc(r:Request, p:Params):Future[Response]
) =
  self.middlewares.add(
    MiddlewareRoute(
      httpMethods: httpMethods,
      path: path,
      action: action
    )
  )

func get*(self:var Routes, path:string, action:proc(r:Request, p:Params):Future[Response]) =
  add(self, HttpGet, path, action)

func post*(self:var Routes, path:string, action:proc(r:Request, p:Params):Future[Response]) =
  add(self, HttpPost, path, action)

func put*(self:var Routes, path:string, action:proc(r:Request, p:Params):Future[Response]) =
  add(self, HttpPut, path, action)

func patch*(self:var Routes, path:string, action:proc(r:Request, p:Params):Future[Response]) =
  add(self, HttpPatch, path, action)

func delete*(self:var Routes, path:string, action:proc(r:Request, p:Params):Future[Response]) =
  add(self, HttpDelete, path, action)

func head*(self:var Routes, path:string, action:proc(r:Request, p:Params):Future[Response]) =
  add(self, HttpHead, path, action)

func options*(self:var Routes, path:string, action:proc(r:Request, p:Params):Future[Response]) =
  add(self, HttpOptions, path, action)

func trace*(self:var Routes, path:string, action:proc(r:Request, p:Params):Future[Response]) =
  add(self, HttpTrace, path, action)

func connect*(self:var Routes, path:string, action:proc(r:Request, p:Params):Future[Response]) =
  add(self, HttpConnect, path, action)

macro groups*(head, body:untyped):untyped =
  var newNode = ""
  for row in body:
    let rowNode = fmt"""
{row[0].repr}("{head}{row[1]}", {row[2].repr})
"""
    newNode.add(rowNode)
  return parseStmt(newNode)

const errorStatusArray* = [505, 504, 503, 502, 501, 500, 451, 431, 429, 428, 426,
  422, 421, 418, 417, 416, 415, 414, 413, 412, 411, 410, 409, 408, 407, 406,
  405, 404, 403, 401, 400, 307, 305, 304, 303, 302, 301, 300]

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
  return Http400
""")

func checkHttpCode(exception:ref Exception):HttpCode =
  ## Generated by macro createHttpCodeError.
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


proc runMiddleware(req:Request, routes:Routes, headers:HttpHeaders):Future[Response] {.async.} =
  var
    headers = headers
    status = HttpCode(0)
  for route in routes.middlewares:
    if route.httpMethods.len > 0:
      if findAll(req.path, route.path).len > 0 and route.httpMethods.contains(req.httpMethod):
        let params = req.params(route)
        let res = await route.action(req, params)
        headers &= res.headers
        if res.status != HttpCode(0): status = res.status
    else:
      if findAll(req.path, route.path).len > 0:
        let params = req.params(route)
        let res = await route.action(req, params)
        headers &= res.headers
        if res.status != HttpCode(0): status = res.status
  let response = Response(headers:headers, status:status)
  return response

proc runController(req:Request, route:Route, headers: HttpHeaders):Future[Response] {.async.} =
  let params = req.params(route)
  let response = await route.action(req, params)
  response.headers &= headers
  echoLog(&"{$response.status}  {req.hostname}  {$req.httpMethod}  {req.path}")
  return response

proc doesRunAnonymousLogin(req:Request, res:Response):bool =
  if res.isNil:
    return false
  if not ENABLE_ANONYMOUS_COOKIE:
    return false
  if req.httpMethod == HttpOptions:
    return false
  if res.headers.hasKey("set-cookie"):
    return false
  # if not req.headers.hasKey("content-type"):
  #   return false
  # if req.headers["content-type"].split(";")[0] == "application/json":
  #   return false
  return true

proc serveCore(params:(Routes, int)){.thread, async.} =
  let (routes, port) = params
  var server = newAsyncHttpServer(true, true)

  proc cb(req: Request) {.async, gcsafe.} =
    var
      headers = newHttpHeaders()
      response = Response(status:HttpCode(0), headers:newHttpHeaders())
    # static file response
    if req.path.contains("."):
      let filepath = getCurrentDir() & "/public" & req.path
      if fileExists(filepath):
        let file = openAsync(filepath, fmRead)
        let data = await file.readAll()
        let contentType = newMimetypes().getMimetype(req.path.split(".")[^1])
        headers["content-type"] = contentType
        response = Response(status:Http200, body:data, headers:headers)
    else:
      # check path match with controller routing → run middleware → run controller
      try:
        let httpMethod =
          if req.httpMethod == HttpHead:
            HttpGet
          else:
            req.httpMethod
        let key = $(httpMethod) & ":" & req.path
        if req.httpMethod == HttpOptions:
          response = await runMiddleware(req, routes, headers)
        elif routes.withoutParams.hasKey(key):
          response = await runMiddleware(req, routes, headers)
          let route = routes.withoutParams[key]
          response = await runController(req, route, response.headers)
        else:
          for route in routes.withParams:
            if route.httpMethod == httpMethod and isMatchUrl(req.path, route.path):
              response = await runMiddleware(req, routes, response.headers)
              if httpMethod != HttpOptions:
                response = await runController(req, route, response.headers)
                break
        if req.httpMethod == HttpHead:
          response.body = ""
      except:
        headers["content-type"] = "text/html; charset=utf-8"
        let exception = getCurrentException()
        if exception.name == "DD".cstring:
          var msg = exception.msg
          msg = msg.replace(re"Async traceback:[.\s\S]*")
          response = Response(status:Http200, body:ddPage(msg), headers:headers)
        elif exception.name == "ErrorAuthRedirect".cstring:
          headers["location"] = exception.msg
          headers["set-cookie"] = "session_id=; expires=31-Dec-1999 23:59:59 GMT" # Delete session id
          response = Response(status:Http302, body:"", headers:headers)
        elif exception.name == "ErrorRedirect".cstring:
          headers["location"] = exception.msg
          response = Response(status:Http302, body:"", headers:headers)
        else:
          let status = checkHttpCode(exception)
          response = Response(status:status, body:errorPage(status, exception.msg), headers:headers)
          echoErrorMsg(&"{$response.status}  {req.hostname}  {$req.httpMethod}  {req.path}")
          echoErrorMsg(exception.msg)

      # anonymous user login should run only for response from controler
      if doesRunAnonymousLogin(req, response):
        let client = await newClient(req)
        if await anonumousCreateSession(client, req):
          # create new session
          response = await response.setCookie(client)
        else:
          # keep session id from request and update expire
          var cookie = newCookie(req)
          cookie.updateExpire(SESSION_TIME, Minutes)
          response = response.setCookie(cookie)

    # if response.isNil:
    if response.status == HttpCode(0):
      headers["content-type"] = "text/html; charset=utf-8"
      response = Response(status:Http404, body:errorPage(Http404, ""), headers:headers)
      echoErrorMsg(&"{$response.status}  {req.hostname}  {$req.httpMethod}  {req.path}")

    response.headers.setDefaultHeaders()

    await req.respond(response.status, response.body, response.headers.format())
    # keep-alive
    req.dealKeepAlive()
  # asyncCheck server.serve(Port(port), cb, HOST_ADDR)
  # runForever()
  server.listen(Port(port))
  while true:
    if server.shouldAcceptRequest():
      await server.acceptRequest(cb)
    else:
      poll()


proc serve*(routes: var Routes) =
  let numThreads =
    when compileOption("threads"):
      countProcessors()
    else:
      1

  if numThreads == 1:
    echo("Starting 1 thread")
  else:
    echo("Starting ", numThreads, " threads")

  echo("Listening on ", &"{HOST_ADDR}:{PORT_NUM}")
  when compileOption("threads"):
    var threads = newSeq[Thread[(Routes, int)]](numThreads)
    for i in 0 ..< numThreads:
      createThread(
        threads[i], serveCore, (routes, PORT_NUM)
      )
    asyncCheck joinThreads(threads)
    runForever()
  else:
    asyncCheck serveCore((routes, PORT_NUM))
    runForever()
