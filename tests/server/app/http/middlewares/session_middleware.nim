import std/asyncdispatch
import std/options
import std/times
import ../../../../../src/basolato/core/baseEnv
import ../../../../../src/basolato/middleware
import ../../../../../src/basolato/core/security/cookie
import ../../../../../src/basolato/core/security/session


proc sessionFromCookie*(c:Context, p:Params):Future[Response] {.async.} =
  var cookies = Cookies.new(c.request)
  let sessionId = cookies.get("session_id")
  let sessionOpt = Session.new(sessionId).await
  await c.setSession(sessionOpt.get())
  await c.session.updateCsrfToken()
  let newSessionId = await c.session.getToken()
  cookies.set("session_id", newSessionId, expire=timeForward(SESSION_TIME, Minutes))
  return next().setCookie(cookies)
