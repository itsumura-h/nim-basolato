import std/asyncdispatch
import std/httpcore
import std/strutils
import ../core/base; export base
import ../core/route; export route
import ../core/header; export header
import ../core/response; export response
import ../core/security/cookie; export cookie
import ../core/security/session_db
import ../core/security/context; export context
import ../middleware

when defined(httpbeast) or defined(httpx):
  import ../core/libservers/nostd/request; export request
else:
  import ../core/libservers/std/request; export request


proc checkSessionId*(request:Request):Future[MiddlewareResult] {.async.} =
  ## Check session id in cookie is valid.
  result = MiddlewareResult()
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
      return MiddlewareResult.new(true, getCurrentExceptionMsg())
