import times, strutils, tables
# 3rd party
import jester/private/utils
# framework
import base, private

proc newCookie*(name, value: string, expires="",
                    sameSite: SameSite=Lax, secure = false,
                    httpOnly = false, domain = "", path = "/"): string =
  ## Creates a cookie which stores ``value`` under ``name``.
  ##
  ## The SameSite argument determines the level of CSRF protection that
  ## you wish to adopt for this cookie. It's set to Lax by default which
  ## should protect you from most vulnerabilities. Note that this is only
  ## supported by some browsers:
  ## https://caniuse.com/#feat=same-site-cookie-attribute
  return makeCookie(name, value, expires, domain, path, secure, httpOnly, sameSite)

proc newCookie*(name, value: string, expires: DateTime,
                    sameSite: SameSite=Lax, secure = false,
                    httpOnly = false, domain = "", path = "/"): string =
  ## Creates a cookie which stores ``value`` under ``name``.
  newCookie(name, value,
            format(expires.utc, "ddd',' dd MMM yyyy HH:mm:ss 'GMT'"),
            sameSite, secure, httpOnly, domain, path)

proc getCookie*(request:Request, key:string): string =
  result = ""
  if not request.headers.hasKey("Cookie"):
    return result
  let cookiesStrArr = request.headers["Cookie"].split("; ")
  for row in cookiesStrArr:
    let rowArr = row.split("=")
    if rowArr[0] == key:
      result = rowArr[1]

proc setCookie*(response:Response, content:string): Response =
  ## maybe content would be token
  # resonse.header("Set-cookie", content)
  response.headers.add(
    ("Set-cookie", content)
  )
  return response


proc updateCookieExpire*(response:Response, request:Request, key:string, days:int, path="/"): Response =
  let content = newCookie(key, request.getCookie(key),
            format(daysForward(days).utc, "ddd',' dd MMM yyyy HH:mm:ss 'GMT'"),
            Lax, false, false, "", path)
  response.header("Set-cookie", content)

proc deleteCookie*(response:Response, key:string, path="/"): Response =
  let cookie = newCookie(key, "", daysForward(-1), path=path)
  response.header("Set-cookie", cookie)

proc deleteCookies*(response:Response, request:Request, path="/"): Response =
  block:
    var response = response
    for row in request.headers["Cookie"].split("; "):
      let rowArr = row.split("=")
      let cookie = newCookie(rowArr[0], "", daysForward(-1), path=path)
      response = response.setCookie(cookie)
    return response
