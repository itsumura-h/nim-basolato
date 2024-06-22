import std/asyncdispatch
import std/options
import std/times
import ../../../../src/basolato/settings
import ../../../../src/basolato/middleware
import ../../../../src/basolato/core/security/cookie
import ../../../../src/basolato/core/security/session


proc sessionFromCookie*(c:Context, p:Params):Future[Response] {.async.} =
  let sessionId = Cookies.new(c.request).get("session_id")
  let sessionOpt = Session.new(sessionId).await
  sessionOpt.updateCsrfToken().await
  c.setSession(sessionOpt.get())
  let newSessionId = sessionOpt.getToken().await
  var cookies = Cookies.new(c.request)
  cookies.set("session_id", newSessionId, expire=timeForward(settings.settings.sessionTime, Minutes))
  return next().setCookie(cookies)
