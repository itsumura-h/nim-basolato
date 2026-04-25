import std/asynchttpserver except Request
import std/asyncdispatch
import std/asyncfile
import std/httpcore
import std/os
import std/re
import std/strutils
import std/strformat
import std/mimetypes
import ../../base
import ../../settings
import ../../error_page
import ../../header
import ../../logger
import ../../resources/dd_page
import ../../response
import ../../route
import ./request


type ServeCoreArg = tuple[routes:Routes, host:string, port:int]

proc userAgent(req: Request): string =
  let values = req.headers.values("User-Agent")
  if values.len > 0:
    return values[0]
  return ""

proc serveCore(arg:ServeCoreArg){.async.} =
  let (routes, host, port) = arg
  var server = newAsyncHttpServer(true, true)
  let publicRoot = getCurrentDir() / "public"
  let mimeTypes = newMimetypes()

  proc cb(rawReq: RawRequest) {.async, gcsafe.} =
    let req = rawReq.toRequest()
    var response = Response.new(HttpCode(0), "", newHttpHeaders())

    try:
      # static file response
      if req.path.contains("."):
        if req.path.contains("/.."):
          raise newException(ErrorHttpParse, "")
        let filepath = publicRoot & req.path
        if fileExists(filepath):
          let file = openAsync(filepath, fmRead)
          let data = file.readAll().await
          let contentType = mimeTypes.getMimetype(req.path.split(".")[^1])
          var headers = newHttpHeaders()
          headers["content-type"] = contentType
          response = Response.new(Http200, data, headers)
      else:
        # check path match with controller routing → run middleware → run controller
        let routeMatch = routes.matchRoute(req.httpMethod, req.path)
        if not routeMatch.route.isNil:
          # Nim 2.2+: same GC-safety note as nostd/server.nim (issue #375).
          {.cast(gcsafe).}:
            response = createResponse(req, routeMatch.route, req.httpMethod, routeMatch.pathParams).await

        if req.httpMethod == HttpHead:
          response.setBody("")
    except DD:
      var headers = newHttpHeaders()
      headers["content-type"] = "text/html; charset=utf-8"
      var msg = getCurrentExceptionMsg()
      msg = msg.replace(re"Async traceback:[.\s\S]*")
      response = Response.new(Http200, ddPage(msg), headers)
    except ErrorHttpParse:
      var headers = newHttpHeaders()
      response = Response.new(Http501, "", headers)
    except:
      var headers = newHttpHeaders()
      let msg = getCurrentExceptionMsg()
      let status = Http500
      response = Response.new(status, msg, headers)

    if response.status.is4xx:
      var headers = newHttpHeaders()
      headers["content-type"] = "text/html; charset=utf-8"
      let userAgent = req.userAgent()
      echoErrorMsg(&"{$response.status}  {$req.httpMethod}  {req.path}  {req.hostname}  {userAgent}")
      response = Response.new(response.status, errorPage(response.status, response.body), headers)
    elif response.status.is5xx:
      var headers = newHttpHeaders()
      headers["content-type"] = "text/html; charset=utf-8"
      let userAgent = req.userAgent()
      echoErrorMsg(&"{$response.status}  {$req.httpMethod}  {req.path}  {req.hostname}  {userAgent}")
      echoErrorMsg(response.body)
      response = Response.new(response.status, errorPage(response.status, response.body), headers)
    elif response.status == HttpCode(0):
      var headers = newHttpHeaders()
      headers["content-type"] = "text/html; charset=utf-8"
      let userAgent = req.userAgent()
      echoErrorMsg(&"{$Http404}  {$req.httpMethod}  {req.path}  {req.hostname}  {userAgent}")
      response = Response.new(Http404, errorPage(Http404, ""), headers)

    response.headers.setDefaultHeaders()
    rawReq.respond(response.status, response.body, response.headers.format()).await


  server.listen(Port(port), host)
  while true:
    if server.shouldAcceptRequest():
      await server.acceptRequest(cb)
    else:
      # too many concurrent connections, `maxFDs` exceeded
      poll()


proc serve*(seqRoutes: seq[Routes], settings:Settings) =
  let routes = Routes.merge(seqRoutes)

  let host = settings.host
  let port = settings.port
  echo(&"Basolato based on asynchttpserver listening on {host}:{port}")
  serveCore((routes:routes, host:host, port:port)).waitFor()
