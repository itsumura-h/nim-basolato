import
  std/asyncdispatch,
  std/asyncfile,
  std/asynchttpserver,
  std/json,
  std/macros,
  std/mimetypes,
  std/os,
  std/re,
  std/strformat,
  std/strutils,
  std/tables,
  std/times
from osproc import countProcessors
import
  ./baseEnv,
  ./error_page,
  ./header,
  ./logger,
  ./request,
  ./response,
  ./resources/dd_page,
  ./security/cookie,
  ./security/context
export request, header


type Middleware = ref object
  action: proc(c:Context, p:Params):Future[Response]

type Route* = ref object
  httpMethod:HttpMethod
  path:string
  controller:proc(c:Context, p:Params):Future[Response]
  middlewares: seq[Middleware]

func new(_:type Route,
  httpMethod:HttpMethod,
  path:string,
  controller:proc(c:Context, p:Params):Future[Response]
):Route =
  return Route(
    httpMethod:httpMethod,
    path:path,
    controller:controller
  )

func new(_:type Route,
  httpMethod:HttpMethod,
  path:string,
  controller:proc(c:Context, p:Params):Future[Response],
  middlewares:seq[Middleware],
):Route =
  return Route(
    httpMethod:httpMethod,
    path:path,
    controller:controller,
    middlewares:middlewares
  )

type Routes = ref object
  withParams: seq[Route]
  withoutParams: OrderedTableRef[string, Route]

func new(_:type Routes):Routes =
  return Routes(
    withParams: newSeq[Route](),
    withoutParams: newOrderedTable[string, Route](),
  )

func add(
  httpMethod: HttpMethod,
  path: string,
  action: proc(c:Context, p:Params):Future[Response],
):Routes =
  let routes = Routes.new()
  let route = Route.new(httpMethod, path, action)
  if path.contains("{"):
    routes.withParams.add(route)
  else:
    routes.withoutParams[ $httpMethod & ":" & path ] = route
    if not [HttpGet, HttpHead].contains(httpMethod):
      routes.withoutParams[ $(HttpOptions) & ":" & path ] = route
  return routes

func get*(
  _:type Route,
  path:string,
  action:proc(c:Context, p:Params):Future[Response],
):Routes =
  return add(HttpGet, path, action)

func post*(
  _:type Route,
  path:string,
  action:proc(c:Context, p:Params):Future[Response]
):Routes =
  add(HttpPost, path, action)

func put*(
  _:type Route,
  path:string,
  action:proc(c:Context, p:Params):Future[Response]
):Routes =
  add(HttpPut, path, action)

func patch*(
  _:type Route,
  path:string,
  action:proc(c:Context, p:Params):Future[Response]
):Routes =
  add(HttpPatch, path, action)

func delete*(
  _:type Route,
  path:string,
  action:proc(c:Context, p:Params):Future[Response]
):Routes =
  add(HttpDelete, path, action)

func head*(
  _:type Route,
  path:string,
  action:proc(c:Context, p:Params):Future[Response]
):Routes =
  add(HttpHead, path, action)

func options*(
  _:type Route,
  path:string,
  action:proc(c:Context, p:Params):Future[Response]
):Routes =
  add(HttpOptions, path, action)

func trace*(
  _:type Route,
  path:string,
  action:proc(c:Context, p:Params):Future[Response]
):Routes =
  add(HttpTrace, path, action)

func connect*(
  _:type Route,
  path:string,
  action:proc(c:Context, p:Params):Future[Response]
):Routes =
  add(HttpConnect, path, action)

func group*(_:type Route, path:string, seqRoutes:seq[Routes]):Routes =
  let routes = Routes.new()
  for tmpRoutes in seqRoutes:
    for k, route in tmpRoutes.withoutParams.pairs:
      let httpMethod = k.split(":")[0]
      let key = k.split(":")[1]
      routes.withoutParams[httpMethod & ":" & path & key] = route
    for route in tmpRoutes.withParams:
      route.path = path & route.path
      routes.withParams.add(route)
  return routes


func middleware*(self:Routes, middleware:proc(c:Context, p:Params):Future[Response]):Routes =
  let data = Middleware(action:middleware)
  for route in self.withParams:
    if not route.middlewares.contains(data):
      route.middlewares.add(data)
  for path, route in self.withoutParams:
    if not route.middlewares.contains(data):
      route.middlewares.add(data)

  return self

proc params(request:Request, route:Route):Params =
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

proc runMiddleware(req:Request, route:Route, headers:HttpHeaders, context:Context):Future[Response] {.async.} =
  var
    headers = headers
    status = HttpCode(0)
  let params = req.params(route)
  for middleware in route.middlewares:
    let res = await middleware.action(context, params)
    headers &= res.headers
    if res.status != HttpCode(0): status = res.status
  let response = Response(headers:headers, status:status)
  return response

proc runController(req:Request, route:Route, headers: HttpHeaders, context:Context):Future[Response] {.async.} =
  let params = req.params(route)
  let response = await route.controller(context, params)
  response.headers &= headers
  echoLog(&"{$response.status}  {req.hostname}  {$req.httpMethod}  {req.path}")
  return response

proc createResponse(req:Request, route:Route, httpMethod:HttpMethod, headers:HttpHeaders, context:Context):Future[Response] {.async.} =
  var
    headers = headers
    response = Response(status:HttpCode(0), headers:newHttpHeaders())

  response = await runMiddleware(req, route, headers, context)
  if ENABLE_ANONYMOUS_COOKIE:
    await context.updateNonce()
  if httpMethod != HttpOptions:
    response = await runController(req, route, response.headers, context)
  return response

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

proc doesRunAnonymousLogin(req:Request, res:Response):bool =
  if res.isNil:
    return false
  if not ENABLE_ANONYMOUS_COOKIE:
    return false
  if req.httpMethod == HttpOptions:
    return false
  if res.headers.hasKey("set-cookie"):
    return false
  return true

proc serveCore(params:(Routes, int)){.async.} =
  {.gcsafe.}:
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
        let context = await Context.new(req, ENABLE_ANONYMOUS_COOKIE)
        try:
          let httpMethod =
            if req.httpMethod == HttpHead:
              HttpGet
            else:
              req.httpMethod
          let key = $(httpMethod) & ":" & req.path

          # withoutParams
          if routes.withoutParams.hasKey(key):
            let route = routes.withoutParams[key]
            response = await createResponse(req, route, httpMethod, headers, context)
          # withParams
          else:
            for route in routes.withParams:
              if route.httpMethod == httpMethod and isMatchUrl(req.path, route.path):
                response = await createResponse(req, route, httpMethod, headers, context)
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
        if doesRunAnonymousLogin(req, response) and await context.isValid():
          # keep session id from request and update expire
          var cookies = Cookies.new(req)
          let sessionId = await context.getToken()
          cookies.set("session_id", sessionId, expire=timeForward(SESSION_TIME, Minutes))
          response = response.setCookie(cookies)

      if response.status == HttpCode(0):
        headers["content-type"] = "text/html; charset=utf-8"
        response = Response(status:Http404, body:errorPage(Http404, ""), headers:headers)
        echoErrorMsg(&"{$response.status}  {req.hostname}  {$req.httpMethod}  {req.path}")

      response.headers.setDefaultHeaders()

      await req.respond(response.status, response.body, response.headers.format())
      # keep-alive
      req.dealKeepAlive()


    server.listen(Port(port), HOST_ADDR)
    while true:
      if server.shouldAcceptRequest():
        await server.acceptRequest(cb)
      else:
        # too many concurrent connections, `maxFDs` exceeded
        # wait 500ms for FDs to be closed
        await sleepAsync(500)

proc runHTTPServer*(seqRoutes: seq[Routes]) {.thread.} =
  var routes =  Routes.new()
  for tmpRoutes in seqRoutes:
    routes.withParams.add(tmpRoutes.withParams)
    for path, route in tmpRoutes.withoutParams:
      routes.withoutParams[path] = route

  asyncCheck serveCore((routes, PORT_NUM))
  runForever()

proc serve*(seqRoutes: seq[Routes]) =
  when compileOption("threads"):
    let numThreads =  countProcessors()
  else:
    let numThreads = 1

  echo(&"Listening on {HOST_ADDR}:{PORT_NUM} Starting {numThreads} threads")

  if numThreads > 1:
    when compileOption("threads"):
      var thr = newSeq[Thread[seq[Routes]]](numThreads)
      for i in 1..numThreads:
        createThread(thr[i-1], runHTTPServer, seqRoutes)
      joinThreads(thr)
  else:
    runHTTPServer(seqRoutes)

# reference
# https://github.com/Oples/tf2-stats/blob/master/src/web_server.nim
# https://github.com/dom96/httpbeast/blob/master/src/httpbeast.nim
# https://forum.nim-lang.org/t/7703
