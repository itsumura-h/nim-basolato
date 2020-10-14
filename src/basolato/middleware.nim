import asynchttpserver, strutils
export asynchttpserver
import core/base, core/route, core/security
export base, route, security


type Check* = ref object
  status*:bool
  msg*:string

proc catch*(this:Check, error:typedesc=Error400, msg="") =
  if not this.status:
    var newMsg = ""
    if msg.len == 0:
      newMsg = this.msg
    else:
      newMsg = msg
    raise newException(error, newMsg)

# =============================================================================

proc checkCsrfToken*(request:Request, params:Params):Check =
  result = Check(status:true)
  if request.reqMethod == HttpPost and not request.path.contains("api/"):
    try:
      if not params.requestParams.hasKey("csrf_token"):
        raise newException(Exception, "csrf token is missing")
      let token = params.requestParams.get("csrf_token")
      discard newCsrfToken(token).checkCsrfTimeout()
    except:
      result = Check(
        status:false,
        msg:getCurrentExceptionMsg()
      )

proc checkAuthToken*(request:Request):Check =
  ## Check session id in cookie is valid.
  result = Check(status:true)
  let cookie = newCookie(request)
  if cookie.hasKey("session_id"):
    try:
      let sessionId = cookie.get("session_id")
      if sessionId.len == 0:
        raise newException(Exception, "Session id is empty")
      if not checkSessionIdValid(sessionId):
        raise newException(Exception, "Invalid session id")
    except:
      result = Check(
        status:false,
        msg:getCurrentExceptionMsg()
      )

proc checkApiToken*(request:Request):Check =
  if (request.reqMethod == HttpPost or request.reqMethod == HttpPut or
        request.reqMethod == HttpPatch or request.reqMethod == HttpDelete) and
        request.path.contains("api/"):
    result = Check(status:true)
