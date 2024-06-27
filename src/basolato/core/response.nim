import std/asyncdispatch
import std/httpcore
import std/json
import std/strutils
import std/times
import ./settings
import ./logger
import ./security/context
import ./security/cookie
import ./security/session
import ./templates


proc component*(arg:string):Component =
  let component = Component.new()
  component.add(arg)
  return component


type Response* = ref object
  status*:HttpCode
  body:string
  headers*:HttpHeaders

proc new*(_:type Response, status:HttpCode, body:string, headers:HttpHeaders):Response =
  return Response(status:status, body:body, headers:headers)

proc body*(self:Response):string =
  return self.body

proc setBody*(self:Response, body:string) =
  self.body = body

func render*(status:HttpCode, body:string):Response =
  let headers = newHttpHeaders(true)
  headers["Content-Type"] = "text/plain; charset=utf-8"
  return Response(
    status:status,
    body:body,
    headers: headers
  )

proc render*(status:HttpCode, body:string, headers:HttpHeaders):Response =
  if not headers.hasKey("Content-Type"):
    headers["Content-Type"] = "text/plain; charset=utf-8"
  return Response(
    status:status,
    body:body,
    headers: headers
  )

func render*(body:string):Response =
  let headers = newHttpHeaders(true)
  headers["Content-Type"] = "text/plain; charset=utf-8"
  return Response(
    status:Http200,
    body:body,
    headers: headers
  )

func render*(body:string, headers:HttpHeaders):Response =
  if not headers.hasKey("Content-Type"):
    headers["Content-Type"] = "text/plain; charset=utf-8"
  return Response(
    status:Http200,
    body:body,
    headers: headers
  )

func render*(status:HttpCode, body:Component):Response =
  let headers = newHttpHeaders(true)
  headers["Content-Type"] = "text/html; charset=utf-8"
  return Response(
    status:status,
    body: $body,
    headers: headers
  )

proc render*(status:HttpCode, body:Component, headers:HttpHeaders):Response =
  if not headers.hasKey("Content-Type"):
    headers["Content-Type"] = "text/html; charset=utf-8"
  return Response(
    status:status,
    body: $body,
    headers: headers
  )

func render*(body:Component):Response =
  let headers = newHttpHeaders(true)
  headers["Content-Type"] = "text/html; charset=utf-8"
  return Response(
    status:Http200,
    body: $body,
    headers: headers
  )

func render*(body:Component, headers:HttpHeaders):Response =
  if not headers.hasKey("Content-Type"):
    headers["Content-Type"] = "text/html; charset=utf-8"
  return Response(
    status:Http200,
    body: $body,
    headers: headers
  )

func render*(status:HttpCode, body:JsonNode):Response =
  let headers = newHttpHeaders(true)
  headers["Content-Type"] = "application/json; charset=utf-8"
  return Response(
    status:status,
    body: $body,
    headers: headers
  )

func render*(body:JsonNode):Response =
  let headers = newHttpHeaders(true)
  headers["Content-Type"] = "application/json; charset=utf-8"
  return Response(
    status:Http200,
    body: $body,
    headers: headers
  )

proc render*(body:JsonNode, headers:HttpHeaders):Response =
  if not headers.hasKey("Content-Type"):
    headers["Content-Type"] = "application/json; charset=utf-8"
  return Response(
    status:Http200,
    body: $body,
    headers: headers
  )

proc render*(status:HttpCode, body:JsonNode, headers:HttpHeaders):Response =
  if not headers.hasKey("Content-Type"):
    headers["Content-Type"] = "application/json; charset=utf-8"
  return Response(
    status:status,
    body: $body,
    headers: headers
  )

func redirect*(url:string):Response =
  let headers = newHttpHeaders(true)
  headers["Location"] = url
  return Response(
    status:Http303,
    body: "",
    headers: headers
  )

func redirect*(url:string, headers:HttpHeaders):Response =
  headers["Location"] = url
  return Response(
    status:Http303,
    body: "",
    headers: headers
  )

func errorRedirect*(url:string):Response =
  let headers = newHttpHeaders(true)
  headers["Location"] = url
  return Response(
    status:Http302,
    body: "",
    headers: headers
  )

func errorRedirect*(url:string, headers:HttpHeaders):Response =
  headers["Location"] = url
  return Response(
    status:Http302,
    body: "",
    headers: headers
  )

# ========== Client ====================
proc setCookie*(response:Response, context:Context):Future[Response] {.async.} =
  let sessionId = await context.session.getToken()

  if SESSION_TIME > 0 and COOKIE_DOMAINS.len > 0:
    for domain in COOKIE_DOMAINS:
      let newDomain = domain.strip()
      let cookie = Cookie.new(
        "session_id",
        sessionId,
        expire=timeForward(SESSION_TIME, Minutes),
        domain=newDomain,
      ).toCookieStr()
      response.headers.add("Set-Cookie", cookie)
  elif SESSION_TIME == 0 and COOKIE_DOMAINS.len > 0:
    for domain in COOKIE_DOMAINS:
      let newDomain = domain.strip()
      let cookie = Cookie.new(
        "session_id",
        sessionId,
        domain=newDomain,
      ).toCookieStr()
      response.headers.add("Set-Cookie", cookie)
  elif SESSION_TIME > 0 and COOKIE_DOMAINS.len == 0:
    let cookie = Cookie.new(
      "session_id",
      sessionId,
      expire=timeForward(SESSION_TIME, Minutes),
    ).toCookieStr()
    response.headers.add("Set-Cookie", cookie)
  else:
    let cookie = Cookie.new("session_id", sessionId).toCookieStr()
    response.headers.add("Set-Cookie", cookie)

  return response


# ========== Cookie ====================
proc setCookie*(response:Response, cookies:Cookies):Response =
  for cookie in cookies.data:
    let cookieStr = cookie.toCookieStr()
    response.headers.add("Set-Cookie", cookieStr)
  return response


proc destroyContext*(response:Response, context:Context):Future[Response] {.async.} =
  if await context.isLogin:
    let cookie = Cookie.new("session_id", "", timeForward(-1, Days))
                  .toCookieStr()
    response.headers.add("Set-Cookie", cookie)
    await context.session.destroy()
  else:
    echoErrorMsg("Tried to destroy client but not logged in")
  return response
