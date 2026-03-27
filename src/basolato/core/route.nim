import std/asyncdispatch
import std/httpcore
import std/json
import std/macros
import std/re
import std/strformat
import std/strutils
import std/tables
import ./header
import ./logger
import ./response
import ./params
import ./security/cookie
import ./security/context

when defined(httpbeast) or defined(httpx):
  from ./libservers/nostd/request import Request, path, httpMethod, headers, body
else:
  from ./libservers/std/request import Request, path, httpMethod


type Controller* = proc(context:Context):Future[Response] {.async.}

type Middleware* = object
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

type RouteParamType = enum
  RouteParamInt
  RouteParamStr

type RouteParamDef = object
  name: string
  typ: RouteParamType

type RouteEntry = ref object
  route: Route
  paramDefs: seq[RouteParamDef]

type RouteMatcherNode = ref object
  staticChildren: TableRef[string, RouteMatcherNode]
  intChild: RouteMatcherNode
  strChild: RouteMatcherNode
  entries: TableRef[HttpMethod, RouteEntry]

type RouteMatcher = ref object
  root: RouteMatcherNode

type RouteMatch* = object
  route*: Route
  pathParams*: Params

type Routes* = ref object
  withParams*: seq[Route]
  withoutParams*: TableRef[string, Route]
  matcher: RouteMatcher
  matcherReady: bool

func newRouteMatcherNode(): RouteMatcherNode =
  return RouteMatcherNode(
    staticChildren: newTable[string, RouteMatcherNode](),
    entries: newTable[HttpMethod, RouteEntry](),
  )

func newRouteMatcher(): RouteMatcher =
  return RouteMatcher(root: newRouteMatcherNode())

func new*(_:type Routes):Routes =
  return Routes(
    withParams: newSeq[Route](),
    withoutParams: newTable[string, Route](),
    matcher: newRouteMatcher(),
    matcherReady: false,
  )

func isNumericSlice(path: string, start, segEnd: int): bool =
  ## Check if the slice of the path is numeric.
  if segEnd <= start:
    return false
  var i = start
  while i < segEnd:
    if not path[i].isDigit:
      return false
    inc i
  return true

func isStringSlice(path: string, start, segEnd: int): bool =
  ## Check if the slice of the path is string.
  segEnd > start and not isNumericSlice(path, start, segEnd)

func segmentMatchesKey(path: string, start, segEnd: int, key: string): bool =
  ## Check if the segment of the path matches the key.
  let n = segEnd - start
  if key.len != n:
    return false
  var i = 0
  while i < n:
    if path[start + i] != key[i]:
      return false
    inc i
  return true

func nextSegmentEnd(path: string, start, pathEnd: int): int =
  ## Find the end of the next segment in the path.
  result = start
  while result < pathEnd and path[result] != '/':
    inc result

func splitPathSegments(path:string):seq[string] =
  ## Split the path into segments.
  let pathWithoutQuery = path.split("?")[0]
  if pathWithoutQuery.len == 0 or pathWithoutQuery == "/":
    return @[]

  var normalizedPath = pathWithoutQuery
  if normalizedPath[0] == '/':
    normalizedPath = normalizedPath[1..^1]
  if normalizedPath.len == 0:
    return @[]

  return normalizedPath.split("/")

func parseParamSegment(
  segment:string,
  name:var string,
  typ:var RouteParamType
):bool =
  ## Parse the segment of the path to get the name and type of the parameter.
  if segment.len < 5:
    return false
  if not segment.startsWith("{") or not segment.endsWith("}"):
    return false

  let body = segment[1..^2]
  let separatorPos = body.rfind(':')
  if separatorPos <= 0 or separatorPos >= body.len - 1:
    return false

  name = body[0..<separatorPos]
  let routeParamType = body[separatorPos + 1..^1]
  if name.len == 0:
    return false

  case routeParamType
  of "int":
    typ = RouteParamInt
    return true
  of "str":
    typ = RouteParamStr
    return true
  else:
    return false

proc addMatcherEntry(
  matcher:RouteMatcher,
  httpMethod:HttpMethod,
  path:string,
  route:Route,
  overwrite:bool
) =
  var node = matcher.root
  var paramDefs = newSeq[RouteParamDef]()
  let segments = splitPathSegments(path)

  for segment in segments:
    var paramName = ""
    var paramType = RouteParamInt
    if parseParamSegment(segment, paramName, paramType):
      case paramType
      of RouteParamInt:
        if node.intChild.isNil:
          node.intChild = newRouteMatcherNode()
        node = node.intChild
      of RouteParamStr:
        if node.strChild.isNil:
          node.strChild = newRouteMatcherNode()
        node = node.strChild
      paramDefs.add(RouteParamDef(name: paramName, typ: paramType))
    else:
      if not node.staticChildren.hasKey(segment):
        node.staticChildren[segment] = newRouteMatcherNode()
      node = node.staticChildren[segment]

  if overwrite or not node.entries.hasKey(httpMethod):
    node.entries[httpMethod] = RouteEntry(route: route, paramDefs: paramDefs)

proc parseMethodAndPath(
  key:string,
  httpMethod:var HttpMethod,
  path:var string
):bool =
  let separatorPos = key.find(":")
  if separatorPos <= 0 or separatorPos >= key.len - 1:
    return false

  let methodName = key[0..<separatorPos]
  path = key[separatorPos + 1..^1]
  try:
    httpMethod = parseEnum[HttpMethod](methodName)
  except ValueError:
    return false
  return true

proc matchNode(
  node: RouteMatcherNode,
  httpMethod: HttpMethod,
  path: string,
  pathEnd: int,
  pos: int,
  capturedValues: var seq[string],
  routeEntry: var RouteEntry
): bool =
  if pos >= pathEnd:
    if node.entries.hasKey(httpMethod):
      routeEntry = node.entries[httpMethod]
      return true
    return false

  let segEnd = nextSegmentEnd(path, pos, pathEnd)

  for key, child in node.staticChildren.pairs:
    if segmentMatchesKey(path, pos, segEnd, key):
      let nextPos = if segEnd < pathEnd: segEnd + 1 else: pathEnd
      if matchNode(child, httpMethod, path, pathEnd, nextPos, capturedValues, routeEntry):
        return true
      break

  if not node.intChild.isNil and isNumericSlice(path, pos, segEnd):
    capturedValues.add(path[pos ..< segEnd])
    let nextPos = if segEnd < pathEnd: segEnd + 1 else: pathEnd
    if matchNode(node.intChild, httpMethod, path, pathEnd, nextPos, capturedValues, routeEntry):
      return true
    capturedValues.setLen(capturedValues.len - 1)

  if not node.strChild.isNil and isStringSlice(path, pos, segEnd):
    capturedValues.add(path[pos ..< segEnd])
    let nextPos = if segEnd < pathEnd: segEnd + 1 else: pathEnd
    if matchNode(node.strChild, httpMethod, path, pathEnd, nextPos, capturedValues, routeEntry):
      return true
    capturedValues.setLen(capturedValues.len - 1)

  return false

proc match(
  matcher:RouteMatcher,
  httpMethod:HttpMethod,
  path:string
):RouteMatch =
  if matcher.isNil:
    return RouteMatch(route: nil, pathParams: nil)

  var pathEnd = path.len
  for i in 0 ..< path.len:
    if path[i] == '?':
      pathEnd = i
      break

  var start = 0
  if pathEnd > 0 and path[0] == '/':
    start = 1

  var routeEntry: RouteEntry
  var capturedValues = newSeq[string]()
  if not matchNode(matcher.root, httpMethod, path, pathEnd, start, capturedValues, routeEntry):
    return RouteMatch(route: nil, pathParams: nil)

  var pathParams: Params = nil
  if routeEntry.paramDefs.len > 0:
    pathParams = Params.new()
    for i, paramDef in routeEntry.paramDefs:
      if i < capturedValues.len:
        pathParams[paramDef.name] = Param.new(capturedValues[i])

  return RouteMatch(route: routeEntry.route, pathParams: pathParams)

proc compileMatcher*(self:Routes) =
  let matcher = newRouteMatcher()
  for key, route in self.withoutParams.pairs:
    var httpMethod = HttpGet
    var path = ""
    if parseMethodAndPath(key, httpMethod, path):
      matcher.addMatcherEntry(httpMethod, path, route, overwrite=true)

  for route in self.withParams:
    matcher.addMatcherEntry(route.httpMethod, route.path, route, overwrite=false)

  self.matcher = matcher
  self.matcherReady = true

proc matchRoute*(self:Routes, httpMethod:HttpMethod, path:string):RouteMatch =
  if not self.matcherReady or self.matcher.isNil:
    self.compileMatcher()
  return self.matcher.match(httpMethod, path)

proc merge*(_:type Routes, seqRoutes:seq[Routes]):Routes =
  let routes = Routes.new()
  for tmpRoutes in seqRoutes:
    routes.withParams.add(tmpRoutes.withParams)
    for path, route in tmpRoutes.withoutParams.pairs:
      routes.withoutParams[path] = route
  routes.compileMatcher()
  return routes

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
  routes.matcherReady = false
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
  routes.matcherReady = false
  return routes


func middleware*(self:Routes, middleware: Controller):Routes =
  let data = Middleware(action:middleware)
  for route in self.withParams:
    if not route.middlewares.contains(data):
      # route.middlewares.add(data)
      route.middlewares.insert(data, 0)
  for path, route in self.withoutParams:
    if not route.middlewares.contains(data):
      # route.middlewares.add(data)
      route.middlewares.insert(data, 0)

  return self


proc runMiddleware(req:Request, context:Context, route:Route):Future[Response] {.async.} =
  var
    headers = newHttpHeaders(true)
    status = HttpCode(0)
    body = ""
  for middleware in route.middlewares:
    let res = middleware.action(context).await
    headers = headers & res.headers

    if res.status.is3xx or res.status.is4xx:
      status = res.status
      body = res.body
      break
    elif res.status != HttpCode(0):
      status = res.status

  return Response.new(status=status, body=body, headers=headers)


proc runController(req:Request, context:Context, route:Route, headers: HttpHeaders):Future[Response] {.async.} =
  let response = route.controller(context).await
  response.headers &= headers
  echoLog(&"{$response.status}  {$req.httpMethod}  {req.path}")
  return response


proc createResponse*(
  req:Request,
  route:Route,
  httpMethod:HttpMethod,
  pathParams:Params=nil
):Future[Response] {.async.} =
  ## run middleware -> run controller
  let context = Context.new(req, pathParams).await
  let response1 = runMiddleware(req, context, route).await
  if httpMethod == HttpOptions:
    return response1
  if response1.status != HttpCode(0):
    return response1
  let response2 = runController(req, context, route, response1.headers).await
  return response2


# const errorStatusArray* = [505, 504, 503, 502, 501, 500, 451, 431, 429, 428, 426,
#   422, 421, 418, 417, 416, 415, 414, 413, 412, 411, 410, 409, 408, 407, 406,
#   405, 404, 403, 401, 400, 307, 305, 304, 303, 302, 301, 300]


# macro createHttpCodeError():untyped =
#   var strBody = ""
#   for num in errorStatusArray:
#     strBody.add(fmt"""
# of "Error{num.repr}":
#   return Http{num.repr}
# """)
#   return parseStmt(fmt"""
# case $exception.name
# {strBody}
# else:
#   return Http400
# """)

# func checkHttpCode*(exception:ref Exception):HttpCode =
#   ## Generated by macro createHttpCodeError.
#   ## List is httpCodeArray
#   ## .. code-block:: nim
#   ##   case $exception.name
#   ##   of Error505:
#   ##     return Http505
#   ##   of Error504:
#   ##     return Http504
#   ##   of Error503:
#   ##     return Http503
#   ##   .
#   ##   .
#   createHttpCodeError

# proc doesRunAnonymousLogin*(req:Request, res:Response):bool =
#   if not ENABLE_ANONYMOUS_COOKIE:
#     return false
#   if res.isNil:
#     return false
#   if req.httpMethod() == HttpOptions:
#     return false
#   if res.headers.hasKey("set-cookie"):
#     return false
#   return true
