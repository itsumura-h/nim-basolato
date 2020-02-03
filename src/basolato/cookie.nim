import times, strutils, tables
# 3rd party
import jester/private/utils
# framework
import base, private

type Cookie* = ref object
  request:Request
  cookies*:seq[string]

proc createCookie*(name, value: string, expires="",
                    sameSite: SameSite=Lax, secure = false,
                    httpOnly = false, domain = "", path = "/"): string =
  ## https://github.com/dom96/jester/blob/4c3965259891de174c059dfc9165dfe8d6ddc600/jester.nim#L716
  return makeCookie(name, value, expires, domain, path, secure, httpOnly, sameSite)

proc createCookie*(name, value: string, expires:DateTime,
                    sameSite: SameSite=Lax, secure = false,
                    httpOnly = false, domain = "", path = "/"): string =
  createCookie(name, value,
    format(expires.utc, "ddd',' dd MMM yyyy HH:mm:ss 'GMT'"),
    sameSite, secure, httpOnly, domain, path)

proc minutesForward*(minutes:int): DateTime =
  return getTime().utc + initTimeInterval(minutes = minutes)

proc newCookie*(request:Request):Cookie =
  return Cookie(request:request)

proc set*(this:Cookie, name, value: string, expires:DateTime,
      sameSite: SameSite=Lax, secure = false, httpOnly = false, domain = "", path = "/"):Cookie =
  let cookie = createCookie(name, value,
                format(expires.utc, "ddd',' dd MMM yyyy HH:mm:ss 'GMT'"),
                sameSite, secure, httpOnly, domain, path)
  this.cookies.add(cookie)
  return this

proc set*(this:Cookie, name, value: string, sameSite: SameSite=Lax,
      secure = false, httpOnly = false, domain = "", path = "/"):Cookie =
  let expires = minutesForward(CSRF_TIME)
  let cookie = createCookie(name, value,
                format(expires.utc, "ddd',' dd MMM yyyy HH:mm:ss 'GMT'"),
                sameSite, secure, httpOnly, domain, path)
  this.cookies.add(cookie)
  return this
      

proc getCookie*(request:Request, key:string): string =
  result = ""
  if not request.headers.hasKey("Cookie"):
    return result
  let cookiesStrArr = request.headers["Cookie"].split("; ")
  for row in cookiesStrArr:
    let rowArr = row.split("=")
    if rowArr[0] == key:
      result = rowArr[1]

proc setCookie*(response:Response, cookie:Cookie):Response =
  for row in cookie.cookies:
    response.headers.add(("Set-cookie", row))
  echo response.headers
  return response  

proc setCookie*(response:Response, content:string): Response =
  # resonse.header("Set-cookie", content)
  response.headers.add(
    ("Set-cookie", content)
  )
  return response


proc updateCookieExpire*(response:Response, request:Request, key:string, days:int, path="/"): Response =
  let content = createCookie(key, request.getCookie(key),
            format(daysForward(days).utc, "ddd',' dd MMM yyyy HH:mm:ss 'GMT'"),
            Lax, false, false, "", path)
  response.header("Set-cookie", content)

proc deleteCookie*(response:Response, key:string, path="/"): Response =
  let cookie = createCookie(key, "", daysForward(-1), path=path)
  response.header("Set-cookie", cookie)

proc deleteCookies*(response:Response, request:Request, path="/"): Response =
  block:
    var response = response
    for row in request.headers["Cookie"].split("; "):
      let rowArr = row.split("=")
      let cookie = createCookie(rowArr[0], "", daysForward(-1), path=path)
      response = response.setCookie(cookie)
    return response
