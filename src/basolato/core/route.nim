import std/asyncdispatch
import std/httpcore
import std/json
import std/macros
import std/os
import std/re
import std/strformat
import std/strutils
import std/tables
import ./baseEnv
import ./header
import ./logger
import ./response
import ./security/cookie
import ./security/context
import ../controller

when defined(httpbeast) or defined(httpx):
  import ./libservers/nostd/request
else:
  import ./libservers/std/request


type Middleware* = ref object
  action: Controller

proc action*(self:Middleware):Controller =
  return self.action

type Route* = ref object
  httpMethod:HttpMethod
  path:string
  controller:Controller
  middlewares: seq[Middleware]

func new(_:type Route,
  httpMethod:HttpMethod,
  path:string,
  controller:Controller
):Route =
  return Route(
    httpMethod:httpMethod,
    path:path,
    controller:controller
  )

func new(_:type Route,
  httpMethod:HttpMethod,
  path:string,
  controller:Controller,
  middlewares:seq[Middleware],
):Route =
  return Route(
    httpMethod:httpMethod,
    path:path,
    controller:controller,
    middlewares:middlewares
  )

func httpMethod*(self:Route):HttpMethod =
  return self.httpMethod

func path*(self:Route):string =
  return self.path

# ==================================================

type Routes* = ref object
  withParams*: seq[Route]
  withoutParams*: OrderedTableRef[string, Route]

func new*(_:type Routes):Routes =
  return Routes(
    withParams: newSeq[Route](),
    withoutParams: newOrderedTable[string, Route](),
  )

func add(
  httpMethod: HttpMethod,
  path: string,
  action: Controller,
):Routes =
  let routes = Routes.new()
  let route = Route.new(httpMethod, path, action)
  if path.contains("{"):
    if not [HttpGet, HttpHead].contains(httpMethod):
      routes.withParams.add(Route.new(HttpOptions, path, action))
    elif httpMethod == HttpGet:
      routes.withParams.add(Route.new(HttpHead, path, action))
    routes.withParams.add(route)
  else:
    if not [HttpGet, HttpHead].contains(httpMethod):
      routes.withoutParams[ $(HttpOptions) & ":" & path ] = route
    elif httpMethod == HttpGet:
      routes.withoutParams[ $(HttpHead) & ":" & path ] = route
    routes.withoutParams[ $httpMethod & ":" & path ] = route
  return routes

func get*(
  _:type Route,
  path:string,
  action:Controller,
):Routes =
  return add(HttpGet, path, action)

func post*(
  _:type Route,
  path:string,
  action:Controller
):Routes =
  add(HttpPost, path, action)

func put*(
  _:type Route,
  path:string,
  action:Controller
):Routes =
  add(HttpPut, path, action)

func patch*(
  _:type Route,
  path:string,
  action:Controller
):Routes =
  add(HttpPatch, path, action)

func delete*(
  _:type Route,
  path:string,
  action:Controller
):Routes =
  add(HttpDelete, path, action)

func head*(
  _:type Route,
  path:string,
  action:Controller
):Routes =
  add(HttpHead, path, action)

func options*(
  _:type Route,
  path:string,
  action:Controller
):Routes =
  add(HttpOptions, path, action)

func trace*(
  _:type Route,
  path:string,
  action:Controller
):Routes =
  add(HttpTrace, path, action)

func connect*(
  _:type Route,
  path:string,
  action:Controller
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


func middleware*(self:Routes, middleware:Controller):Routes =
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
  let params = Params.new()
  for k, v in getUrlParams(url, path).pairs:
    params[k] = v
  for k, v in getQueryParams(request).pairs:
    params[k] = v

  if request.headers.hasKey("Content-Type") and request.headers["Content-Type"].split(";")[0] == "application/json":
    for k, v in getJsonParams(request).pairs:
      params[k] = v
  else:
    for k, v in getRequestParams(request).pairs:
      params[k] = v
  return params


proc runMiddleware(req:Request, route:Route, context:Context):Future[Response] {.async.} =
  var
    headers = newHttpHeaders(true)
    status = HttpCode(0)
  let params = req.params(route)
  for middleware in route.middlewares:
    let res = middleware.action(context, params).await
    headers &= res.headers
    if res.status != HttpCode(0): status = res.status
  return Response(headers:headers, status:status)


proc runController(req:Request, route:Route, headers: HttpHeaders, context:Context):Future[Response] {.async.} =
  let params = req.params(route)
  let response = route.controller(context, params).await
  response.headers &= headers
  echoLog(&"{$response.status}  {$req.httpMethod}  {req.path}")
  return response


proc createResponse*(req:Request, route:Route, httpMethod:HttpMethod, context:Context):Future[Response] {.async.} =
  let response1 = runMiddleware(req, route, context).await
  if ENABLE_ANONYMOUS_COOKIE:
    await context.updateNonce()
  if httpMethod == HttpOptions:
    return response1
  let response2 = runController(req, route, response1.headers, context).await
  return response2


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

func checkHttpCode*(exception:ref Exception):HttpCode =
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

proc doesRunAnonymousLogin*(req:Request, res:Response):bool =
  if not ENABLE_ANONYMOUS_COOKIE:
    return false
  if res.isNil:
    return false
  if req.httpMethod() == HttpOptions:
    return false
  if res.headers.hasKey("set-cookie"):
    return false
  return true
