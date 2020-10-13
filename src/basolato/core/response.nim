import httpcore, json, strutils, times
import baseEnv, header, security, logger

type Response* = ref object
  status*:HttpCode
  body*:string
  headers*:Headers


proc render*(status:HttpCode, body:string):Response =
  var headers = newDefaultHeaders()
  headers.set("Content-Type", "text/html; charset=UTF-8")
  return Response(
    status:status,
    body:body,
    headers: headers
  )

proc render*(status:HttpCode, body:string, headers:var Headers):Response =
  if not headers.hasKey("Content-Type"):
    headers.set("Content-Type", "text/html; charset=UTF-8")
  headers.setDefaultHeaders()
  return Response(
    status:status,
    body:body,
    headers: headers
  )

proc render*(body:string, headers:var Headers):Response =
  if not headers.hasKey("Content-Type"):
    headers.set("Content-Type", "text/html; charset=UTF-8")
  headers.setDefaultHeaders()
  return Response(
    status:Http200,
    body:body,
    headers: headers
  )

proc render*(body:string):Response =
  var headers = newDefaultHeaders()
  headers.set("Content-Type", "text/html; charset=UTF-8")
  return Response(
    status:Http200,
    body:body,
    headers: headers
  )

proc render*(status:HttpCode, body:JsonNode):Response =
  var headers = newDefaultHeaders()
  headers.set("Content-Type", "application/json; charset=utf-8")
  return Response(
    status:status,
    body: $body,
    headers: headers
  )

proc render*(status:HttpCode, body:JsonNode, headers:var Headers):Response =
  if not headers.hasKey("Content-Type"):
    headers.set("Content-Type", "application/json; charset=utf-8")
  headers.setDefaultHeaders()
  return Response(
    status:status,
    body: $body,
    headers: headers
  )

proc render*(body:JsonNode, headers:var Headers):Response =
  if not headers.hasKey("Content-Type"):
    headers.set("Content-Type", "application/json; charset=utf-8")
  headers.setDefaultHeaders()
  return Response(
    status:Http200,
    body: $body,
    headers: headers
  )

proc render*(body:JsonNode):Response =
  var headers = newDefaultHeaders()
  headers.set("Content-Type", "application/json; charset=utf-8")
  return Response(
    status:Http200,
    body: $body,
    headers: headers
  )

proc redirect*(url:string):Response =
  var headers = newDefaultHeaders()
  headers.set("Location", url)
  return Response(
    status:Http303,
    body: "",
    headers: headers
  )

proc errorRedirect*(url:string):Response =
  var headers = newDefaultHeaders()
  headers.set("Location", url)
  return Response(
    status:Http302,
    body: "",
    headers: headers
  )

# ========== Auth ====================
proc setAuth*(response:Response, auth:Auth):Response =
  let sessionId = auth.getToken()
  let cookie = if SESSION_TIME.len > 0:
    newCookieData(
      "session_id",
      sessionId,
      timeForward(SESSION_TIME.parseInt, Minutes)
    )
    .toCookieStr()
  else:
    newCookieData("session_id", sessionId).toCookieStr()

  response.headers.add(("Set-cookie", cookie))
  return response


# ========== Cookie ====================
proc setCookie*(response:Response, cookie:Cookie):Response =
  for cookieData in cookie.cookies:
    let cookieStr = cookieData.toCookieStr()
    # response.headers.add(("Set-cookie", cookieStr))
    response.headers.set("Set-cookie", cookieStr)
  return response


proc destroyAuth*(response:Response, auth:Auth):Response =
  if auth.isLogin:
    let sessionId = auth.getToken()
    let cookie = newCookieData("session_id", sessionId, timeForward(-1, Days))
                  .toCookieStr()
    response.headers.add(("Set-cookie", cookie))
    auth.destroy()
  else:
    echoErrorMsg("Tried to destroy auth but not logged in")
  return response