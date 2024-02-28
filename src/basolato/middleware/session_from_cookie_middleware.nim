import std/asyncdispatch
import std/httpcore
import std/options
import std/times
import std/strutils
import ../core/security/context
import ../core/security/session
import ../core/security/cookie
import ../core/baseEnv
import ../core/logger
import ../middleware


proc createExpire():int =
  return now().toTime().toUnix() + (60 * 30) # 60 secound * 30 min

proc sessionFromCookie*(c:Context, p:Params):Future[Response] {.async.} =
  try:
    var cookies = Cookies.new(c.request)
    let sessionId = cookies.get("session_id")
    let sessionOpt = Session.new(sessionId).await
    c.setSession(sessionOpt.get())
    # get expire time
    let expire =
      if sessionOpt.isSome("csrf_expire").await:
        sessionOpt.get("csrf_expire").await.parseInt().fromUnix()
      else:
        fromUnix(0)
    let current = now().toTime()
    if c.request.httpMethod == HttpGet and ( current > expire ):
      c.session.updateCsrfToken().await
      let newExpire = createExpire()
      c.session.set("csrf_expire", $newExpire).await
    else:
      globalCsrfToken = sessionOpt.get("csrf_token").await

    let newSessionId = sessionOpt.getToken().await
    cookies.set("session_id", newSessionId, expire=timeForward(SESSION_TIME, Minutes))
    return next().setCookie(cookies)
  except:
    echoErrorMsg(getCurrentExceptionMsg())
    return render(Http500, getCurrentExceptionMsg())
