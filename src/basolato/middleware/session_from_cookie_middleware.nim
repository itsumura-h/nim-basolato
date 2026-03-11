import std/asyncdispatch
import std/httpcore
import std/options
import std/times
import std/json
import std/strutils
import ../core/security/context
import ../core/security/session
import ../core/security/cookie
import ../core/security/jwt
import ../core/settings
import ../core/logger
import ../core/settings
import ../middleware


proc createExpire():int =
  return ( now().toTime().toUnix() + (60 * 30) ).int # 60 secound * 30 min

proc sessionFromCookie*(c:Context, p:Params):Future[Response] {.async.} =
  var cookies = Cookies.new(c.request)
  let sessionPayload = cookies.get("session")
  let (sessionDecoded, valid) = Jwt.decode(sessionPayload, settings.SECRET_KEY)
  
  let sessionOpt = 
    if valid:
      let sessionId = sessionDecoded["session_id"].getStr()
      Session.new(sessionId).await
    else:
      Session.new().await

  c.setSession(sessionOpt.get())
  # get expire time
  let expire =
    if (await c.session.isSome("csrf_expire")):
      (await c.session.get("csrf_expire")).parseInt().fromUnix()
    else:
      fromUnix(0)
  let current = now().toTime()
  if c.request.httpMethod == HttpGet and ( current > expire ):
    await c.session.updateCsrfToken()
    let newExpire = createExpire()
    await c.session.set("csrf_expire", $newExpire)
  else:
    globalCsrfToken = await c.session.get("csrf_token")

  let newSessionId = await c.session.getToken()
  let newPayload = %*{
    "session_id": newSessionId,
    "iat": now().toTime().toUnix(),
    "exp": (now() + initTimeInterval(minutes=SESSION_TIME)).toTime().toUnix(),
  }
  let newSession = Jwt.encode($newPayload, settings.SECRET_KEY)
  cookies.set("session", newSession, expire=timeForward(SESSION_TIME, Minutes))
  return next().setCookie(cookies)
