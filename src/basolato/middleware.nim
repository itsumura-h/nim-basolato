import std/asyncdispatch
import std/httpcore; export httpcore
import std/strutils
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


proc parseJwtAlgorithm(jwtAlg: string): JwtAlgorithm =
  case jwtAlg.toUpperAscii()
  of "HS256":
    jwtHS256
  of "ES256":
    jwtES256
  of "EDDSA":
    jwtEdDSA
  of "RS256":
    jwtRS256
  of "PS256":
    jwtPS256
  else:
    raise newException(ValueError, "unsupported JWT algorithm: " & jwtAlg)


proc checkCsrfTokenForMpaHelper*(context:Context, jwtAlg: string) {.async.} =
  ## Checking csrf token between request param and cookie is valid.
  ## 
  ## This middleware implements the Double Submit Cookie pattern
  ## 
  ## If csrf token is not valid, throw error
  ## 
  ## jwtAlg is the JWT algorithm to use for the session.
  ## "HS256", "ES256", "EDDSA", "RS256", "PS256" are supported.
  if context.request.httpMethod != HttpPost:
    return
  
  if not context.params.hasKey("csrf_token"):
    raise newException(CatchableError, "csrf token is missing")
  let tokenFromParam = context.params.getStr("csrf_token")
  let algorithm = parseJwtAlgorithm(jwtAlg)
  let sessionKey = Jwt.secretKey(algorithm, SECRET_KEY)

  let tokenFromJwt =
    if context.decodedSessionJwt.isSome:
      context.decodedSessionJwt.get["csrf_token"].getStr()
    else:
      let jwtToken = Cookies.new(context.request).get("session")
      let jwtValid = Jwt.verify(algorithm, Jwt.publicKey(sessionKey), jwtToken)
      if not jwtValid:
        raise newException(CatchableError, "Invalid jwt token")
      Jwt.decode(jwtToken)["csrf_token"].getStr()
  
  if tokenFromParam != tokenFromJwt:
    raise newException(CatchableError, "Invalid csrf token")


proc checkCsrfTokenForApi*(context: Context, jwtAlg: string) {.async.} =
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
  let algorithm = parseJwtAlgorithm(jwtAlg)
  let sessionKey = Jwt.secretKey(algorithm, SECRET_KEY)

  let tokenFromJwt =
    if context.decodedSessionJwt.isSome:
      context.decodedSessionJwt.get["csrf_token"].getStr()
    else:
      let jwtToken = Cookies.new(context.request).get("session")
      let jwtValid = Jwt.verify(algorithm, Jwt.publicKey(sessionKey), jwtToken)
      if not jwtValid:
        raise newException(CatchableError, "Invalid jwt token")
      Jwt.decode(jwtToken)["csrf_token"].getStr()
  
  if tokenFromHeader != tokenFromJwt:
    raise newException(CatchableError, "Invalid csrf token")


proc createExpire():int =
  return ( now().toTime().toUnix() + (60 * 30) ).int # 60 secound * 30 min


proc sessionFromCookieHelper*(c:Context, jwtAlg: string):Future[Cookies] {.async.} =
  ## create session and set it into context
  ## 
  ## if session is not valid, throw error
  ## 
  ## jwtAlg is the JWT algorithm to use for the session.
  ## "HS256", "ES256", "EDDSA", "RS256", "PS256" are supported.
  var cookies = Cookies.new(c.request)
  let sessionPayload = cookies.get("session")
  let algorithm = parseJwtAlgorithm(jwtAlg)
  let sessionKey = Jwt.secretKey(algorithm, settings.SECRET_KEY)
  let isJwtValid = Jwt.verify(algorithm, Jwt.publicKey(sessionKey), sessionPayload)
  let sessionDecoded =
    if isJwtValid:
      Jwt.decode(sessionPayload)
    else:
      newJObject()

  if not isJwtValid:
    raise newException(CatchableError, "Invalid jwt")

  let sessionId = sessionDecoded["session_id"].getStr()
  let isSessionIdValid = SessionDb.checkSessionIdValid(sessionId).await
  if not isSessionIdValid:
    raise newException(CatchableError, "Invalid session")

  let sessionOpt = Session.new(sessionId).await
  await c.setSession(sessionOpt.get())
  c.setDecodedSessionJwt(sessionDecoded)

  let csrfToken =
    if c.request.httpMethod == HttpGet:
      await c.updateCsrfToken()
    else:
      c.getCsrfToken()

  let newSessionId = await c.session.getToken()
  let newPayload = 
    if SESSION_TIME > 0:
      %*{
        "session_id": newSessionId,
        "csrf_token": csrfToken,
        "iat": now().toTime().toUnix(),
        "exp": timeForward(SESSION_TIME, Minutes).toTime().toUnix(),
      }
    else:
      %*{
        "session_id": newSessionId,
        "csrf_token": csrfToken,
        "iat": now().toTime().toUnix(),
        "exp": timeForward(1, Years).toTime().toUnix(),
      }
  cookies = Cookies.new(c.request)
  let newSession = Jwt.sign(algorithm, newPayload, sessionKey)
  if SESSION_TIME > 0:
    cookies.set("session", newSession, expire=timeForward(SESSION_TIME, Minutes))
  else:
    cookies.set("session", newSession, expire=timeForward(1, Years))
  return cookies


proc createNewSessionHelper*(context:Context, jwtAlg: string):Future[Cookies] {.async.} =
  var cookies = Cookies.new(context.request)
  let session = Session.new().await
  # セッションを context にセットしてからアップデート
  await context.setSession(session.get())
  let csrfToken = await context.updateCsrfToken()
  let newExpire = createExpire()
  await context.session.set("csrf_expire", $newExpire)
  let payload =
    if SESSION_TIME > 0:
      %*{
        "session_id": await context.session.getToken(),
        "csrf_token": csrfToken,
        "iat": now().toTime().toUnix(),
        "exp": timeForward(SESSION_TIME, Minutes).toTime().toUnix(),
      }
    else:
      %*{
        "session_id": await context.session.getToken(),
        "csrf_token": csrfToken,
        "iat": now().toTime().toUnix(),
        "exp": timeForward(1, Years).toTime().toUnix(),
      }
  let algorithm = parseJwtAlgorithm(jwtAlg)
  let jwtToken = Jwt.sign(algorithm, payload, Jwt.secretKey(algorithm, settings.SECRET_KEY))
  if SESSION_TIME > 0:
    cookies.set("session", jwtToken, expire=timeForward(SESSION_TIME, Minutes))
  else:
    cookies.set("session", jwtToken, expire=timeForward(1, Years))
  return cookies
