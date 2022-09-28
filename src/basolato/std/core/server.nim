import std/asynchttpserver
import std/json
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
import ./baseEnv
import ./security/context
import ./security/cookie
import ./route
import ./request
import ./header
import ./response
import ./logger
import ./resources/dd_page
import ./error_page
import ./benchmark

from osproc import countProcessors


proc serveCore(params:(Routes, int)){.async.} =
  let (routes, port) = params
  var server = newAsyncHttpServer(true, true)

  proc cb(req: Request) {.async, gcsafe.} =
    var
      response = Response(status:HttpCode(0), headers:newHttpHeaders())

    try:
      # static file response
      if req.path.contains("."):
        let filepath = getCurrentDir() & "/public" & req.path
        if fileExists(filepath):
          let file = openAsync(filepath, fmRead)
          let data = await file.readAll()
          let contentType = newMimetypes().getMimetype(req.path.split(".")[^1])
          var headers = newHttpHeaders()
          headers["content-type"] = contentType
          response = Response(status:Http200, body:data, headers:headers)
      else:
        # check path match with controller routing → run middleware → run controller
        let key = $(req.httpMethod) & ":" & req.path.split("?")[0]
        let context = await Context.new(req, ENABLE_ANONYMOUS_COOKIE)
        if routes.withoutParams.hasKey(key):
          # withoutParams
          let route = routes.withoutParams[key]
          response = await createResponse(req, route, req.httpMethod, context)
        else:
          # withParams
          for route in routes.withParams:
            if route.httpMethod == req.httpMethod and isMatchUrl(req.path, route.path):
              response = await createResponse(req, route, req.httpMethod, context)
              break

        if req.httpMethod == HttpHead:
          response.body = ""

        # anonymous user login should run only for response from controler
        if doesRunAnonymousLogin(req, response) and context.isValid().await:
          # keep session id from request and update expire
          var cookies = Cookies.new(req)
          let sessionId = await context.getToken()
          cookies.set("session_id", sessionId, expire=timeForward(SESSION_TIME, Minutes))
          response = response.setCookie(cookies)
    except:
      var headers = newHttpHeaders()
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


    if response.status == HttpCode(0):
      var headers = newHttpHeaders()
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

proc serve*(seqRoutes: seq[Routes]) =
  var routes =  Routes.new()
  for tmpRoutes in seqRoutes:
    routes.withParams.add(tmpRoutes.withParams)
    for path, route in tmpRoutes.withoutParams:
      routes.withoutParams[path] = route

  echo(&"Basolato based on asynchttpserver listening on {HOST_ADDR}:{PORT_NUM}")
  asyncCheck serveCore((routes, PORT_NUM))
  runForever()
