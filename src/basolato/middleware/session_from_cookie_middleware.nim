import std/asyncdispatch
import std/options
import std/times
import ../core/baseEnv
import ../core/security/context
import ../core/security/session
import ../core/security/cookie
import ../middleware


proc sessionFromCookie*(c:Context, p:Params):Future[Response] {.async.} =
  try:
    var cookies = Cookies.new(c.request)
    let sessionId = cookies.get("session_id")
    let sessionOpt = Session.new(sessionId).await
    c.setSession(sessionOpt.get())
    if c.request.httpMethod == HttpGet:
      c.session.updateNonce().await
    else:
      globalNonce = sessionOpt.get("nonce").await
    let newSessionId = sessionOpt.getToken().await
    cookies.set("session_id", newSessionId, expire=timeForward(SESSION_TIME, Minutes))
    return next().setCookie(cookies)
  except:
    return render(Http500, getCurrentExceptionMsg())
