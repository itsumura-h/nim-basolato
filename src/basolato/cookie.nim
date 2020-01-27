import times, strutils
# 3rd party
import jester/private/utils
# framework
import base, private

proc genCookie*(name, value: string, expires="",
                    sameSite: SameSite=Lax, secure = false,
                    httpOnly = false, domain = "", path = ""): string =
  ## Creates a cookie which stores ``value`` under ``name``.
  ##
  ## The SameSite argument determines the level of CSRF protection that
  ## you wish to adopt for this cookie. It's set to Lax by default which
  ## should protect you from most vulnerabilities. Note that this is only
  ## supported by some browsers:
  ## https://caniuse.com/#feat=same-site-cookie-attribute
  return makeCookie(name, value, expires, domain, path, secure, httpOnly, sameSite)

proc genCookie*(name, value: string, expires: DateTime,
                    sameSite: SameSite=Lax, secure = false,
                    httpOnly = false, domain = "", path = ""): string =
  ## Creates a cookie which stores ``value`` under ``name``.
  genCookie(name, value,
            format(expires.utc, "ddd',' dd MMM yyyy HH:mm:ss 'GMT'"),
            sameSite, secure, httpOnly, domain, path)

proc getCookie*(request:Request, key:string): string =
  result = ""
  if not request.headers.hasKey("Cookie"):
    return result
  let cookiesStrArr = request.headers["Cookie"].split(";")
  for row in cookiesStrArr:
    let rowArr = row.split("=")
    if rowArr[0] == key:
      result = rowArr[1]

# proc setCookie*(this:Session, expires: DateTime): string =
#   genCookie("token", this.token,
#             format(expires.utc, "ddd',' dd MMM yyyy HH:mm:ss 'GMT'"),
#             Lax, false, false, "", "")

proc setCookie*(r:Response, c:string): Response =
  ## maybe c would be token
  r.header("Set-cookie", c)

proc updateCookieExpire*(response:Response, request:Request, key:string, days:int): Response =
  let c = genCookie(key, request.getCookie(key),
            format(daysForward(days).utc, "ddd',' dd MMM yyyy HH:mm:ss 'GMT'"),
            Lax, false, false, "", "")
  response.header("Set-cookie", c)

proc deleteCookie*(response:Response, key:string): Response =
  let cookie = genCookie(key, "", daysForward(-1))
  response.header("Set-cookie", cookie)

# proc deleteCookies*(response:Response, request: Request): Response =
#   let cookie = genCookie(key, "", daysForward(-1))
#   r.header("Set-cookie", cookie)