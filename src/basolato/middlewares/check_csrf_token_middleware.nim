import std/asyncdispatch
import std/httpcore
import std/strutils
import std/tables
import ../core/base; export base
import ../core/route; export route
import ../core/header; export header
import ../core/response; export response
import ../core/security/cookie; export cookie
import ../core/security/session
import ../core/security/session_db
import ../core/security/csrf_token
import ../core/security/context; export context
import ../middleware

when defined(httpbeast) or defined(httpx):
  import ../core/libservers/nostd/request; export request
else:
  import ../core/libservers/std/request; export request

proc checkCsrfTokenMiddleware*(request:Request, params:Params):Future[MiddlewareResult] {.async.} =
  result = MiddlewareResult()
  if request.httpMethod == HttpPost and not request.headers["Content-Type"].contains("application/json"):
    try:
      if not params.hasKey("csrf_token"):
        raise newException(Exception, "csrf token is missing")
      let token = params.getStr("csrf_token")
      let csrfToken = CsrfToken.new(token)
      let session = Session.new(request).await
      if not csrfToken.checkCsrfValid(session).await:
        raise newException(Exception, "Invalid csrf token")
    except:
      return MiddlewareResult.new(true, getCurrentExceptionMsg())
