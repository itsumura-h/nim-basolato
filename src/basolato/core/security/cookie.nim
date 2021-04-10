import httpcore, asynchttpserver, times, strutils
import ../utils, ../baseEnv

type
  CookieData* = ref object
    name:string
    value:string
    expire:string
    sameSite:SameSite
    secure:bool
    httpOnly:bool
    domain:string
    path:string

  Cookie* = ref object
    request:Request
    cookies*:seq[CookieData]


proc timeForward*(num:int, timeUnit:TimeUnit):DateTime =
  case timeUnit
  of Years:
    return getTime().utc + initTimeInterval(years = num)
  of Months:
    return getTime().utc + initTimeInterval(months = num)
  of Weeks:
    return getTime().utc + initTimeInterval(weeks = num)
  of Days:
    return getTime().utc + initTimeInterval(days = num)
  of Hours:
    return getTime().utc + initTimeInterval(hours = num)
  of Minutes:
    return getTime().utc + initTimeInterval(minutes = num)
  of Seconds:
    return getTime().utc + initTimeInterval(seconds = num)
  of Milliseconds:
    return getTime().utc + initTimeInterval(milliseconds = num)
  of Microseconds:
    return getTime().utc + initTimeInterval(microseconds = num)
  of Nanoseconds:
    return getTime().utc + initTimeInterval(nanoseconds = num)

func toCookieStr*(self:CookieData):string =
  makeCookie(self.name, self.value, self.expire, self.domain, self.path,
              self.secure, self.httpOnly, self.sameSite)


proc newCookieData*(name, value:string, expire:DateTime, sameSite:SameSite=Lax,
      secure=false, httpOnly=true, domain="", path="/"):CookieData =
  let f = initTimeFormat("ddd',' dd MMM yyyy HH:mm:ss 'GMT'")
  let expireStr = format(expire.utc, f)
  when defined(release):
    let secure = true
  CookieData(name:name, value:value,expire:expireStr, sameSite:sameSite,
    secure:secure, httpOnly:httpOnly, domain:domain, path:path)

func newCookieData*(name, value:string, expire="", sameSite: SameSite=Lax,
      secure=false, httpOnly=true, domain = "", path = "/"):CookieData =
  when defined(release):
    let secure = true
  CookieData(name:name, value:value,expire:expire, sameSite:sameSite,
    secure:secure, httpOnly:httpOnly, domain:domain, path:path)

func newCookie*(request:Request):Cookie =
  return Cookie(request:request, cookies:newSeq[CookieData](0))

func cookies(request:Request):Cookie =
  return request.newCookie()

func get*(self:Cookie, name:string):string =
  result = ""
  if not self.request.headers.hasKey("Cookie"):
    return result
  let cookiesStrArr = self.request.headers["Cookie"].split("; ")
  for row in cookiesStrArr:
    let rowArr = row.split("=")
    if rowArr[0] == name:
      result = rowArr[1]
      break

func hasKey*(self:Cookie, name:string):bool =
  if self.get(name).len > 0:
    return true
  else:
    return false

proc add*(self:var Cookie, name, value: string, expire:DateTime,
      sameSite: SameSite=Lax, secure=false, httpOnly=true, domain="",
      path = "/") =
  let f = initTimeFormat("ddd',' dd MMM yyyy HH:mm:ss 'GMT'")
  let expireStr = format(expire.utc, f)
  when defined(release):
    let secure = true
  self.cookies.add(
    newCookieData(name=name, value=value, expire=expireStr, sameSite=sameSite,
      secure=secure, httpOnly=httpOnly, domain=domain, path=path)
  )

proc add*(self:var Cookie, name, value: string, sameSite: SameSite=Lax,
      secure=false, httpOnly=true, domain="", path="/") =
  let expires = timeForward(SESSION_TIME, Minutes)
  let f = initTimeFormat("ddd',' dd MMM yyyy HH:mm:ss 'GMT'")
  let expireStr = format(expires.utc, f)
  when defined(release):
    let secure = true
  self.cookies.add(
    newCookieData(name=name, value=value, expire=expireStr, sameSite=sameSite,
      secure=secure, httpOnly=httpOnly, domain=domain, path=path)
  )

proc updateExpire*(self:var Cookie, name:string, num:int,
                    timeUnit:TimeUnit, path="/") =
  let f = initTimeFormat("ddd',' dd MMM yyyy HH:mm:ss 'GMT'")
  let expireStr = format(timeForward(num, timeUnit).utc, f)
  if self.request.headers.hasKey("Cookie"):
    let cookiesStrArr = self.request.headers["Cookie"].split("; ")

    var
      value:string
      httpOnly:bool
      secure:bool
      domain:string
      path = path
    for i, row in cookiesStrArr:
      let rowArr = row.split("=")
      if rowArr[0] == name:
        value = rowArr[1]
      elif rowArr[0].toLowerAscii == "httponly":
        httpOnly = true
      elif rowArr[0].toLowerAscii == "secure":
        secure = true
      elif rowArr[0].toLowerAscii == "domain":
        domain = rowArr[1]
      elif rowArr[0].toLowerAscii == "path":
        path = rowArr[1]

    self.cookies.add(
      newCookieData(name, value, expire=expireStr, secure=secure,
        httpOnly=httpOnly, domain=domain, path=path)
    )


proc updateExpire*(self:var Cookie, num:int, time:TimeUnit) =
  let f = initTimeFormat("ddd',' dd MMM yyyy HH:mm:ss 'GMT'")
  let expireStr = format(timeForward(num, time).utc, f)
  if self.request.headers.hasKey("Cookie"):
    let cookiesStrArr = self.request.headers["Cookie"].split("; ")
    for row in cookiesStrArr:
      let name = row.split("=")[0]
      let value = row.split("=")[1]
      self.cookies.add(
        newCookieData(name=name, value=value, expire=expireStr)
      )

proc delete*(self:var Cookie, key:string, path="/") =
  self.cookies.add(
    newCookieData(name=key, value="", expire=timeForward(-1, Days), path=path)
  )
