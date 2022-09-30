import std/asyncdispatch
import std/httpcore
import std/strutils
import std/tables
import ./core/base; export base
import ./core/request; export request
import ./core/route; export route
import ./core/header; export header
import ./core/response; export response
import ./core/security/cookie; export cookie
import ./core/security/session
import ./core/security/session_db
import ./core/security/csrf_token
import ./core/security/context; export context


type MiddlewareResult* = ref object
  hasError: bool
  message: string

func hasError*(self:MiddlewareResult):bool =
  return self.hasError

func message*(self:MiddlewareResult):string =
  return self.message

func next*(status:HttpCode=HttpCode(200), body="", headers:HttpHeaders=newHttpHeaders()):Response =
  return Response(status:status, body:body, headers:headers)

proc checkCsrfToken*(request:Request, params:Params):Future[MiddlewareResult] {.async.} =
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
      result.hasError = true
      result.message = getCurrentExceptionMsg()

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
      result.hasError = true
      result.message = getCurrentExceptionMsg()
