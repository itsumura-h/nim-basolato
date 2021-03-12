import httpcore, json, strutils, times, asyncdispatch
import baseEnv, header, security, logger

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

func errorRedirect*(url:string):Response =
  let headers = newHttpHeaders()
  headers["location"] = url
  return Response(
    status:Http302,
    body: "",
    headers: headers
  )

# ========== Auth ====================
proc setAuth*(response:Response, auth:Auth):Future[Response] {.async.} =
  let sessionId = await auth.getToken()
  if SESSION_TIME > 0 and COOKIE_DOMAINS.len > 0:
    for domain in COOKIE_DOMAINS.split(","):
      let newDomain = domain.strip()
      let cookie = newCookieData(
        "session_id",
        sessionId,
        timeForward(SESSION_TIME, Minutes),
        domain=newDomain
      ).toCookieStr()
      response.headers.add("Set-cookie", cookie)
  elif SESSION_TIME == 0 and COOKIE_DOMAINS.len > 0:
    for domain in COOKIE_DOMAINS.split(","):
      let newDomain = domain.strip()
      let cookie = newCookieData(
        "session_id",
        sessionId,
        domain=newDomain
      ).toCookieStr()
      response.headers.add("Set-cookie", cookie)
  elif SESSION_TIME > 0 and COOKIE_DOMAINS.len == 0:
    let cookie = newCookieData(
      "session_id",
      sessionId,
      timeForward(SESSION_TIME, Minutes)
    ).toCookieStr()
    response.headers.add("Set-cookie", cookie)
  else:
    let cookie = newCookieData("session_id", sessionId).toCookieStr()
    response.headers.add("Set-cookie", cookie)

  return response


# ========== Cookie ====================
func setCookie*(response:Response, cookie:Cookie):Response =
  for cookieData in cookie.cookies:
    let cookieStr = cookieData.toCookieStr()
    response.headers.add("Set-cookie", cookieStr)
  return response


proc destroyAuth*(response:Response, auth:Auth):Future[Response] {.async.} =
  if await auth.isLogin:
    let sessionId = await auth.getToken()
    let cookie = newCookieData("session_id", sessionId, timeForward(-1, Days))
                  .toCookieStr()
    response.headers.add("Set-cookie", cookie)
    await auth.destroy()
  else:
    echoErrorMsg("Tried to destroy auth but not logged in")
  return response
