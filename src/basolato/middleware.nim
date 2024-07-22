import std/asyncdispatch
import std/httpcore
import std/strutils
import std/tables
import std/json
import std/options
import std/times
import ./core/base; export base
import ./core/route; export route
import ./core/header; export header
import ./core/response; export response
import ./core/params; export params
import ./core/security/cookie; export cookie
import ./core/security/session
import ./core/security/session_db
import ./core/security/jwt
import ./core/security/context; export context
import ./core/settings

when defined(httpbeast) or defined(httpx):
  import ./core/libservers/nostd/request; export request
else:
  import ./core/libservers/std/request; export request


func next*(status=HttpCode(0), body="", headers:HttpHeaders=newHttpHeaders()):Response =
  ## It returns empty Response
  return Response.new(status, body, headers)


proc checkCsrfTokenForMpaHelper*(context:Context) {.async.} =
  ## Checking csrf token between request param and cookie is valid.
  ## 
  ## This middleware implements the Double Submit Cookie pattern
  ## 
  ## If csrf token is not valid, throw error
  if context.request.httpMethod != HttpPost:
    return
  
  if not context.params.hasKey("csrf_token"):
    raise newException(CatchableError, "csrf token is missing")
  let tokenFromParam = context.params.getStr("csrf_token")
  
  let jwtToken = Cookies.new(context.request).get("session")
  let (jwtDecoded, jwtValid) = Jwt.decode(jwtToken, SECRET_KEY)
  if not jwtValid:
    raise newException(CatchableError, "Invalid jwt token")
  let tokenFromJwt = jwtDecoded["csrf_token"].getStr()
  
  if tokenFromParam != tokenFromJwt:
    raise newException(CatchableError, "Invalid csrf token")


proc checkCsrfTokenForApi*(context: Context) {.async.} =
  ## Checking csrf token between request header and cookie is valid.
  ## 
  ## This function is intended for use in APIs to ensure the CSRF token is valid.
  ##
  ## If the csrf token is not valid, an error is raised.
  if not [HttpPost, HttpPatch, HttpPut, HttpDelete].contains(context.request.httpMethod):
    return

  let tokenFromHeader = context.request.headers["X-CSRF-TOKEN"].toString()
  if tokenFromHeader == "":
    raise newException(CatchableError, "csrf token is missing in request headers")
  
  let jwtToken = Cookies.new(context.request).get("session")
  let (jwtDecoded, jwtValid) = Jwt.decode(jwtToken, SECRET_KEY)
  if not jwtValid:
    raise newException(CatchableError, "Invalid jwt token")
  let tokenFromJwt = jwtDecoded["csrf_token"].getStr()
  
  if tokenFromHeader != tokenFromJwt:
    raise newException(CatchableError, "Invalid csrf token")


proc createExpire():int =
  return ( now().toTime().toUnix() + (60 * 30) ).int # 60 secound * 30 min

proc sessionFromCookieHelper*(c:Context):Future[Cookies] {.async.} =
  ## create session and set it into context
  ## 
  ## if session is not valid, throw error
  var cookies = Cookies.new(c.request)
  let sessionPayload = cookies.get("session")
  let (sessionDecoded, isJwtValid) = Jwt.decode(sessionPayload, settings.SECRET_KEY)

  if not isJwtValid:
    raise newException(CatchableError, "Invalid jwt")

  let sessionId = sessionDecoded["session_id"].getStr()
  let isSessionIdValid = SessionDb.checkSessionIdValid(sessionId).await
  if not isSessionIdValid:
    raise newException(CatchableError, "Invalid session")

  let sessionOpt = Session.new(sessionId).await
  c.setSession(sessionOpt.get())
  
  if c.request.httpMethod == HttpGet:
    sessionOpt.updateCsrfToken().await

  let newSessionId = sessionOpt.getToken().await
  let newPayload = %*{
    "session_id": newSessionId,
    "csrf_token": globalCsrfToken,
    "iat": now().toTime().toUnix(),
    "exp": (now() + initTimeInterval(minutes=SESSION_TIME)).toTime().toUnix(),
  }
  let newSession = Jwt.encode($newPayload, settings.SECRET_KEY)
  cookies.set("session", newSession, expire=timeForward(SESSION_TIME, Minutes))
  return cookies


proc createNewSessionHelper*(context:Context):Future[Cookies] {.async.} =
  var cookies = Cookies.new(context.request)
  let session = Session.new().await
  session.updateCsrfToken().await
  let newExpire = createExpire()
  session.set("csrf_expire", $newExpire).await
  let payload = %*{
    "session_id": session.getToken().await,
    "csrf_token": globalCsrfToken,
    "iat": now().toTime().toUnix(),
    "exp": (now() + initTimeInterval(minutes=SESSION_TIME)).toTime().toUnix(),
  }
  let jwtToken = Jwt.encode($payload, settings.SECRET_KEY)
  cookies.set("session", jwtToken, expire=timeForward(SESSION_TIME, Minutes))
  return cookies
