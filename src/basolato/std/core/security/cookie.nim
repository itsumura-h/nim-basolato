import httpcore, asynchttpserver, times, strutils, tables
import ../baseEnv


type
  SameSite = enum
    None, Lax, Strict

  Cookie* = ref object
    name:string
    value:string
    expire:string
    sameSite:SameSite
    secure:bool
    httpOnly:bool
    domain:string
    path:string

  Cookies* = ref object
    request:Request
    data*:seq[Cookie]


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

func makeCookie(key, value, expires: string, domain = "", path = "",
                 secure = false, httpOnly = false,
                 sameSite = Lax): string =
  result = ""
  result.add key & "=" & value
  if domain != "": result.add("; Domain=" & domain)
  if path != "": result.add("; Path=" & path)
  if expires != "": result.add("; Expires=" & expires)
  if secure: result.add("; Secure")
  if httpOnly: result.add("; HttpOnly")
  if sameSite != None:
    result.add("; SameSite=" & $sameSite)

func toCookieStr*(self:Cookie):string =
  makeCookie(self.name, self.value, self.expire, self.domain, self.path,
              self.secure, self.httpOnly, self.sameSite)


proc new*(_:type Cookie, name, value:string, expire:DateTime, sameSite:SameSite=Lax,
      secure=false, httpOnly=true, domain="", path="/"):Cookie =
  let f = initTimeFormat("ddd',' dd MMM yyyy HH:mm:ss 'GMT'")
  let expireStr = format(expire.utc, f)
  when defined(release):
    let secure = true
  Cookie(name:name, value:value,expire:expireStr, sameSite:sameSite,
    secure:secure, httpOnly:httpOnly, domain:domain, path:path)

func new*(_:type Cookie, name, value:string, expire="", sameSite: SameSite=Lax,
      secure=false, httpOnly=true, domain = "", path = "/"):Cookie =
  when defined(release):
    let secure = true
  Cookie(name:name, value:value,expire:expire, sameSite:sameSite,
    secure:secure, httpOnly:httpOnly, domain:domain, path:path)


func new*(_:type Cookies, request:Request):Cookies =
  return Cookies(request:request, data:newSeq[Cookie](0))

func get*(self:Cookies, name:string):string =
  result = ""
  if not self.request.headers.hasKey("Cookie"):
    return result
  let cookiesStrArr = self.request.headers["Cookie"].split("; ")
  for row in cookiesStrArr:
    let rowArr = row.split("=")
    if rowArr[0] == name:
      result = rowArr[1]
      break

func getAll*(self:Cookies):TableRef[string, string] =
  result = newTable[string, string]()
  if not self.request.headers.hasKey("Cookie"):
    return result
  let cookiesStrArr = self.request.headers["Cookie"].split("; ")
  for row in cookiesStrArr:
    let rowArr = row.split("=")
    result[rowArr[0]] = rowArr[1]

func hasKey*(self:Cookies, name:string):bool =
  if self.get(name).len > 0:
    return true
  else:
    return false

proc set*(self:var Cookies, name, value: string, expire:DateTime,
      sameSite: SameSite=Lax, secure=false, httpOnly=true, domain="",
      path = "/") =
  let f = initTimeFormat("ddd',' dd MMM yyyy HH:mm:ss 'GMT'")
  let expireStr = format(expire.utc, f)
  when defined(release):
    let secure = true
  self.data.add(
    Cookie.new(name=name, value=value, expire=expireStr, sameSite=sameSite,
      secure=secure, httpOnly=httpOnly, domain=domain, path=path)
  )

proc set*(self:var Cookies, name, value: string, sameSite:SameSite=Lax,
      secure=false, httpOnly=true, domain="", path="/") =
  let expires = timeForward(SESSION_TIME, Minutes)
  let f = initTimeFormat("ddd',' dd MMM yyyy HH:mm:ss 'GMT'")
  let expireStr = format(expires.utc, f)
  when defined(release):
    let secure = true
  self.data.add(
    Cookie.new(name=name, value=value, expire=expireStr, sameSite=sameSite,
      secure=secure, httpOnly=httpOnly, domain=domain, path=path)
  )

proc delete*(self:var Cookies, key:string, path="/") =
  self.data.add(
    Cookie.new(name=key, value="", expire=timeForward(-1, Days), path=path)
  )

proc destroy*(self:var Cookies) =
  if self.request.headers.hasKey("Cookie"):
    let cookies = self.getAll()
    for key, val in cookies:
      self.data.add(
        Cookie.new(name=key, value="", expire=timeForward(-1, Days))
      )
