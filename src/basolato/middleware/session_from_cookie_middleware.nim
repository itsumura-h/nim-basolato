import std/asyncdispatch
import std/httpcore
import std/options
import std/times
import ../core/security/context
import ../core/security/session
import ../core/security/cookie
import ../core/baseEnv
import ../core/logger
import ../middleware


proc sessionFromCookie*(c:Context, p:Params):Future[Response] {.async.} =
  try:
    var cookies = Cookies.new(c.request)
    let sessionId = cookies.get("session_id")
    let sessionOpt = Session.new(sessionId).await
    c.setSession(sessionOpt.get())
    if c.request.httpMethod == HttpGet:
      c.session.updateCsrfToken().await
    else:
      globalCsrfToken = sessionOpt.get("csrf_token").await
    let newSessionId = sessionOpt.getToken().await
    cookies.set("session_id", newSessionId, expire=timeForward(SESSION_TIME, Minutes))
    return next().setCookie(cookies)
  except:
    echoErrorMsg(getCurrentExceptionMsg())
    return render(Http500, getCurrentExceptionMsg())
