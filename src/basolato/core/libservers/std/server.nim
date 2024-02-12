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
import ../../baseEnv
import ../../error_page
import ../../header
import ../../logger
import ../../resources/dd_page
import ../../response
import ../../route
import ../../security/context
# import ../../security/cookie
import ./request


proc serveCore(params:(Routes, int)){.async.} =
  let (routes, port) = params
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
        let context = Context.new(req).await
        if routes.withoutParams.hasKey(key):
          # withoutParams
          let route = routes.withoutParams[key]
          response = createResponse(req, route, req.httpMethod, context).await
        else:
          # withParams
          for route in routes.withParams:
            if route.httpMethod == req.httpMethod and isMatchUrl(req.path, route.path):
              response = createResponse(req, route, req.httpMethod, context).await
              break

        if req.httpMethod == HttpHead:
          response.setBody("")
    except:
      var headers = newHttpHeaders()
      headers["content-type"] = "text/html; charset=utf-8"
      let exception = getCurrentException()
      echo "exception.name: ",exception.name
      if exception.name == "DD".cstring:
        var msg = exception.msg
        msg = msg.replace(re"Async traceback:[.\s\S]*")
        response = Response.new(Http200, ddPage(msg), headers)
      elif exception.name == "ErrorAuthRedirect".cstring:
        headers["location"] = exception.msg
        headers["set-cookie"] = "session_id=; expires=31-Dec-1999 23:59:59 GMT" # Delete session id
        response = Response.new(Http302, "", headers)
      elif exception.name == "ErrorRedirect".cstring:
        headers["location"] = exception.msg
        response = Response.new(Http302, "", headers)
      elif exception.name == "ErrorHttpParse".cstring:
        response = Response.new(Http501, "", headers)
      else:
        let status = checkHttpCode(exception)
        response = Response.new(status, errorPage(status, exception.msg), headers)
        echoErrorMsg(&"{$response.status}  {req.hostname}  {$req.httpMethod}  {req.path}")
        echoErrorMsg(exception.msg)

    if response.status.is4xx:
      var headers = newHttpHeaders()
      headers["content-type"] = "text/html; charset=utf-8"
      echoErrorMsg(&"{$response.status}  {req.hostname}  {$req.httpMethod}  {req.path}")
      response = Response.new(response.status, errorPage(response.status, response.body), headers)
    elif response.status.is5xx:
      var headers = newHttpHeaders()
      headers["content-type"] = "text/html; charset=utf-8"
      echoErrorMsg(&"{$response.status}  {req.hostname}  {$req.httpMethod}  {req.path}")
      response = Response.new(response.status, errorPage(response.status, response.body), headers)
    elif response.status == HttpCode(0):
      var headers = newHttpHeaders()
      headers["content-type"] = "text/html; charset=utf-8"
      response = Response.new(Http404, errorPage(Http404, ""), headers)
      echoErrorMsg(&"{$response.status}  {req.hostname}  {$req.httpMethod}  {req.path}")

    response.headers.setDefaultHeaders()
    req.respond(response.status, response.body, response.headers.format()).await
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
  
  # asyncCheck server.serve(Port(port), cb, HOST_ADDR)

proc serve*(seqRoutes: seq[Routes]) =
  var routes =  Routes.new()
  for tmpRoutes in seqRoutes:
    routes.withParams.add(tmpRoutes.withParams)
    for path, route in tmpRoutes.withoutParams:
      routes.withoutParams[path] = route

  echo(&"Basolato based on asynchttpserver listening on {HOST_ADDR}:{PORT_NUM}")
  serveCore((routes, PORT_NUM)).waitFor()
