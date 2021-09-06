import httpcore, json, strutils, times, asyncdispatch
import baseEnv, header, logger, security/cookie, security/session, security/context

type Response* = ref object
  status*:HttpCode
  body*:string
  headers*:HttpHeaders


func render*(status:HttpCode, body:string):Response =
  let headers = newHttpHeaders()
  headers["content-type"] = "text/html; charset=utf-8"
  return Response(
    status:status,
    body:body,
    headers: headers
  )

proc render*(status:HttpCode, body:string, headers:HttpHeaders):Response =
  if not headers.hasKey("content-type"):
    headers["content-type"] = "text/html; charset=utf-8"
  headers.setDefaultHeaders()
  return Response(
    status:status,
    body:body,
    headers: headers
  )

func render*(body:string):Response =
  let headers = newHttpHeaders()
  headers["content-type"] = "text/html; charset=utf-8"
  return Response(
    status:Http200,
    body:body,
    headers: headers
  )

func render*(body:string, headers:HttpHeaders):Response =
  if not headers.hasKey("content-type"):
    headers["content-type"] = "text/html; charset=utf-8"
  return Response(
    status:Http200,
    body:body,
    headers: headers
  )

func render*(status:HttpCode, body:JsonNode):Response =
  let headers = newHttpHeaders()
  headers["content-type"] = "application/json; charset=utf-8"
  return Response(
    status:status,
    body: $body,
    headers: headers
  )

func render*(body:JsonNode):Response =
  let headers = newHttpHeaders()
  headers["content-type"] = "application/json; charset=utf-8"
  return Response(
    status:Http200,
    body: $body,
    headers: headers
  )

proc render*(body:JsonNode, headers:HttpHeaders):Response =
  if not headers.hasKey("content-type"):
    headers["content-type"] = "application/json; charset=utf-8"
  headers.setDefaultHeaders()
  return Response(
    status:Http200,
    body: $body,
    headers: headers
  )

proc render*(status:HttpCode, body:JsonNode, headers:HttpHeaders):Response =
  if not headers.hasKey("content-type"):
    headers["content-type"] = "application/json; charset=utf-8"
  headers.setDefaultHeaders()
  return Response(
    status:status,
    body: $body,
    headers: headers
  )

func redirect*(url:string):Response =
  let headers = newHttpHeaders()
  headers["location"] = url
  return Response(
    status:Http303,
    body: "",
    headers: headers
  )

func redirect*(url:string, headers:HttpHeaders):Response =
  headers["location"] = url
  return Response(
    status:Http303,
    body: "",
    headers: headers
  )

func errorRedirect*(url:string):Response =
  let headers = newHttpHeaders()
  headers["location"] = url
  return Response(
    status:Http302,
    body: "",
    headers: headers
  )

func errorRedirect*(url:string, headers:HttpHeaders):Response =
  headers["location"] = url
  return Response(
    status:Http302,
    body: "",
    headers: headers
  )

# ========== Client ====================
proc setCookie*(response:Response, context:Context):Future[Response] {.async.} =
  let sessionId = await context.session.getToken()
  if SESSION_TIME > 0 and COOKIE_DOMAINS.len > 0:
    for domain in COOKIE_DOMAINS.split(","):
      let newDomain = domain.strip()
      let cookie = newCookie(
        "session_id",
        sessionId,
        expire=timeForward(SESSION_TIME, Minutes),
        domain=newDomain,
      ).toCookieStr()
      response.headers.add("Set-cookie", cookie)
  elif SESSION_TIME == 0 and COOKIE_DOMAINS.len > 0:
    for domain in COOKIE_DOMAINS.split(","):
      let newDomain = domain.strip()
      let cookie = newCookie(
        "session_id",
        sessionId,
        domain=newDomain,
      ).toCookieStr()
      response.headers.add("Set-cookie", cookie)
  elif SESSION_TIME > 0 and COOKIE_DOMAINS.len == 0:
    let cookie = newCookie(
      "session_id",
      sessionId,
      expire=timeForward(SESSION_TIME, Minutes),
    ).toCookieStr()
    response.headers.add("Set-cookie", cookie)
  else:
    let cookie = newCookie("session_id", sessionId).toCookieStr()
    response.headers.add("Set-cookie", cookie)

  return response


# ========== Cookie ====================
proc setCookie*(response:Response, cookie:Cookies):Response =
  for cookie in cookie.data:
    let cookieStr = cookie.toCookieStr()
    response.headers.add("Set-cookie", cookieStr)
  return response


proc destroyContext*(response:Response, context:Context):Future[Response] {.async.} =
  if await context.isLogin:
    let cookie = newCookie("session_id", "", timeForward(-1, Days))
                  .toCookieStr()
    response.headers.add("Set-cookie", cookie)
    await context.session.destroy()
  else:
    echoErrorMsg("Tried to destroy client but not logged in")
  return response
