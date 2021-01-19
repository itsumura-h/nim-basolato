import asynchttpserver, asyncdispatch, strutils
export asynchttpserver
import core/base, core/route, core/security, core/header, core/response
export base, route, security, header, response

type MiddlewareResult* = ref object
  isError: bool
  message: string

proc isError*(this:MiddlewareResult):bool =
  return this.isError

proc message*(this:MiddlewareResult):string =
  return this.message

proc next*(status:HttpCode=HttpCode(200), body="", headers:Headers=newHeaders()):Response =
  return Response(status:status, body:body, headers:headers)

proc checkCsrfToken*(request:Request, params:Params):Future[MiddlewareResult] {.async.} =
  result = MiddlewareResult()
  if request.reqMethod == HttpPost and not request.path.contains("api/"):
    try:
      if not params.hasKey("csrf_token"):
        raise newException(Exception, "csrf token is missing")
      let token = params.getStr("csrf_token")
      discard newCsrfToken(token).checkCsrfTimeout()
    except:
      result.isError = true
      result.message = getCurrentExceptionMsg()

proc checkSessionId*(request:Request):Future[MiddlewareResult] {.async.} =
  ## Check session id in cookie is valid.
  result = MiddlewareResult()
  let cookie = newCookie(request)
  try:
    if not cookie.hasKey("session_id"):
      raise newException(Exception, "Missing session id")
    let sessionId = cookie.get("session_id")
    if sessionId.len == 0:
      raise newException(Exception, "Session id is empty")
    if not await checkSessionIdValid(sessionId):
      raise newException(Exception, "Invalid session id")
  except:
    result.isError = true
    result.message = getCurrentExceptionMsg()
