import std/asyncdispatch
import std/httpcore
import std/strutils
import std/tables
import ./core/base; export base
import ./core/route; export route
import ./core/header; export header
import ./core/response; export response
import ./core/security/cookie; export cookie
import ./core/security/session
import ./core/security/session_db
import ./core/security/csrf_token
import ./core/security/context; export context

when defined(httpbeast) or defined(httpx):
  import ./core/libservers/nostd/request; export request
else:
  import ./core/libservers/std/request; export request


type MiddlewareResult* = object
  hasError: bool
  message: string

proc new(_:type MiddlewareResult, hasError=false, message=""):MiddlewareResult =
  return MiddlewareResult(hasError: hasError, message: message)


func hasError*(self:MiddlewareResult):bool =
  return self.hasError

func message*(self:MiddlewareResult):string =
  return self.message

func next*(status=HttpCode(0), body="", headers:HttpHeaders=newHttpHeaders()):Response =
  return Response.new(status, body, headers)

proc checkCsrfToken*(request:Request, params:Params):Future[MiddlewareResult] {.async.} =
  result = MiddlewareResult.new()
  if request.httpMethod == HttpPost and not (request.headers.hasKey("content-type") and request.headers["content-type"].contains("application/json")):
    try:
      if not params.hasKey("csrf_token"):
        raise newException(Exception, "csrf token is missing")
      let token = params.getStr("csrf_token")
      let csrfToken = CsrfToken.new(token)
      let sessionId = Cookies.new(request).get("session_id")
      let session = Session.new(sessionId).await
      if not csrfToken.checkCsrfValid(session).await:
        raise newException(Exception, "Invalid csrf token")
    except:
      result = MiddlewareResult.new(true, getCurrentExceptionMsg())


proc checkCsrf*(context:Context):Future[MiddlewareResult] {.async.} =
  ## check origin header in request which is sent by same host or allowed host
  result = MiddlewareResult.new()
  try:
    # check origin header
    let request = context.request
    if [HttpPost, HttpPut, HttpPatch, HttpDelete].contains(request.httpMethod):
      let requestOrigin =
        if request.headers.hasKey("origin"):
          request.headers["origin"].toString()
        else:
          ""
      if requestOrigin.len == 0:
        raise newException(Exception, "Origin header is missing")
      if not requestOrigin.contains(context.origin):
        raise newException(Exception, "Invalid origin")
    # check
  except:
    result = MiddlewareResult.new(true, getCurrentExceptionMsg())


proc checkSessionId*(request:Request):Future[MiddlewareResult] {.async.} =
  ## Check session id in cookie is valid.
  result = MiddlewareResult.new()
  if request.httpMethod != HttpOptions:
    let cookie = Cookies.new(request)
    try:
      if not cookie.hasKey("session_id"):
        raise newException(Exception, "Missing session id")
      let sessionId = cookie.get("session_id")
      if sessionId.len == 0:
        raise newException(Exception, "Session id is empty")
      if not SessionDb.checkSessionIdValid(sessionId).await:
        raise newException(Exception, "Invalid session id")
    except:
      result = MiddlewareResult.new(true, getCurrentExceptionMsg())
