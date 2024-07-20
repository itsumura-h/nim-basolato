import std/asynchttpserver
import std/asyncdispatch
import std/asyncfile
import std/httpcore
import std/options
import std/os
import std/re
import std/strutils
import std/strformat
import std/tables
import std/times
import std/mimetypes
import ../../base
import ../../settings
import ../../error_page
import ../../header
import ../../logger
import ../../resources/dd_page
import ../../response
import ../../route
import ../../security/context
import ./request


type ServeCoreArg = tuple[routes:Routes, host:string, port:int]

proc serveCore(arg:ServeCoreArg){.async.} =
  let (routes, host, port) = arg
  var server = newAsyncHttpServer(true, true)

  proc cb(req: Request) {.async, gcsafe.} =
    var response = Response.new(HttpCode(0), "", newHttpHeaders())

    try:
      # static file response
      if req.path.contains("."):
        let filepath = getCurrentDir() & "/public" & req.path
        if fileExists(filepath):
          let file = openAsync(filepath, fmRead)
          let data = file.readAll().await
          let contentType = newMimetypes().getMimetype(req.path.split(".")[^1])
          var headers = newHttpHeaders()
          headers["content-type"] = contentType
          response = Response.new(Http200, data, headers)
      else:
        # check path match with controller routing → run middleware → run controller
        let key = $(req.httpMethod) & ":" & req.path
        # let context = Context.new(req).await
        if routes.withoutParams.hasKey(key):
          # withoutParams
          let route = routes.withoutParams[key]
          response = createResponse(req, route, req.httpMethod).await
        else:
          # withParams
          for route in routes.withParams:
            if route.httpMethod == req.httpMethod and isMatchUrl(req.path, route.path):
              response = createResponse(req, route, req.httpMethod).await
              break

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
      response = Response.new(status, errorPage(status, msg), headers)
      let userAgent = req.headers["User-Agent"]
      echoErrorMsg(&"{$response.status}  {$req.httpMethod}  {req.path}  {req.hostname}  {userAgent}")
      echoErrorMsg(msg)

    if response.status.is4xx:
      var headers = newHttpHeaders()
      headers["content-type"] = "text/html; charset=utf-8"
      let userAgent = req.headers["User-Agent"]
      echoErrorMsg(&"{$response.status}  {$req.httpMethod}  {req.path}  {req.hostname}  {userAgent}")
      response = Response.new(response.status, errorPage(response.status, response.body), headers)
    elif response.status.is5xx:
      var headers = newHttpHeaders()
      headers["content-type"] = "text/html; charset=utf-8"
      let userAgent = req.headers["User-Agent"]
      echoErrorMsg(&"{$response.status}  {$req.httpMethod}  {req.path}  {req.hostname}  {userAgent}")
      response = Response.new(response.status, errorPage(response.status, response.body), headers)
    elif response.status == HttpCode(0):
      var headers = newHttpHeaders()
      headers["content-type"] = "text/html; charset=utf-8"
      let userAgent = req.headers["User-Agent"]
      echoErrorMsg(&"{$Http404}  {$req.httpMethod}  {req.path}  {req.hostname}  {userAgent}")
      response = Response.new(Http404, errorPage(Http404, ""), headers)

    response.headers.setDefaultHeaders()
    req.respond(response.status, response.body, response.headers.format()).await
    # keep-alive
    req.dealKeepAlive()


  server.listen(Port(port), host)
  while true:
    if server.shouldAcceptRequest():
      await server.acceptRequest(cb)
    else:
      # too many concurrent connections, `maxFDs` exceeded
      # wait 500ms for FDs to be closed
      await sleepAsync(500)


proc serve*(seqRoutes: seq[Routes], settings:Settings) =
  var routes =  Routes.new()
  for tmpRoutes in seqRoutes:
    routes.withParams.add(tmpRoutes.withParams)
    for path, route in tmpRoutes.withoutParams:
      routes.withoutParams[path] = route

  let host = settings.host
  let port = settings.port
  echo(&"Basolato based on asynchttpserver listening on {host}:{port}")
  serveCore((routes:routes, host:host, port:port)).waitFor()
