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
import ../../baseEnv
import ../../error_page
import ../../header
import ../../logger
import ../../resources/dd_page
import ../../response
import ../../route
import ../../security/context
import ./request

when defined(httpbeast):
  from httpbeast import send, initSettings, run
else:
  from httpx import send, initSettings, run


proc serve*(seqRoutes:seq[Routes], port=5000) =
  var routes =  Routes.new()
  for tmpRoutes in seqRoutes:
    routes.withParams.add(tmpRoutes.withParams)
    for path, route in tmpRoutes.withoutParams:
      routes.withoutParams[path] = route
  
  proc cd(req:Request):Future[void] {.gcsafe, async.}=
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
          response = createResponse(req, route, req.httpMethod, context).waitFor
        else:
          # withParams
          for route in routes.withParams:
            if route.httpMethod == req.httpMethod and isMatchUrl(req.path, route.path):
              response = createResponse(req, route, req.httpMethod, context).waitFor
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

    # except:
    #   var headers = newHttpHeaders()
    #   headers["content-type"] = "text/html; charset=utf-8"
    #   let exception = getCurrentException()
    #   if exception.name == "DD".cstring:
    #     var msg = exception.msg
    #     msg = msg.replace(re"Async traceback:[.\s\S]*")
    #     response = Response.new(Http200, ddPage(msg), headers)
    #   elif exception.name == "ErrorAuthRedirect".cstring:
    #     headers["location"] = exception.msg
    #     headers["set-cookie"] = "session_id=; expires=31-Dec-1999 23:59:59 GMT" # Delete session id
    #     response = Response.new(Http302, "", headers)
    #   elif exception.name == "ErrorRedirect".cstring:
    #     headers["location"] = exception.msg
    #     response = Response.new(Http302, "", headers)
    #   elif exception.name == "ErrorHttpParse".cstring:
    #     response = Response.new(Http501, "", headers)
    #   else:
    #     let status = checkHttpCode(exception)
    #     response = Response.new(status, errorPage(status, exception.msg), headers)
    #     echoErrorMsg(&"{$response.status}  {$req.httpMethod}  {req.path}")
    #     echoErrorMsg(exception.msg)

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

    when defined(httpbeast):
      req.send(response.status, response.body, response.headers.format().toString())
    else:
      req.send(response.status, response.body, some($response.body.len), response.headers.format().toString())
    # keep-alive
    req.dealKeepAlive()

  
  let settings = initSettings(port=Port(PORT_NUM), bindAddr=HOST_ADDR)
  let libStr = when defined(httpbeast): "httpbeast" elif defined(httpx): "httpx" else: ""
  echo(&"Basolato based on {libStr} listening on {HOST_ADDR}:{PORT_NUM}")
  run(cd, settings)
