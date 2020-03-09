import httpcore, json, options, os, times
# framework
import base, header, security, logger
# 3rd party
import httpbeast
from jester import RawHeaders, CallbackAction, ResponseData
import jester/request


template setHeader(headers: var Option[RawHeaders], key, value: string) =
  ## Customized jester code
  bind isNone
  if isNone(headers):
    headers = some(@({key: value}))
  else:
    block outer:
      # Overwrite key if it exists.
      var h = headers.get()
      if key != "Set-cookie": # multiple cookies should be allowed
        for i in 0 ..< h.len:
          if h[i][0] == key:
            h[i][1] = value
            headers = some(h)
            break outer

      # Add key if it doesn't exist.
      headers = some(h & @({key: value}))

template resp*(code: HttpCode,
               headers: openarray[tuple[key, val: string]],
               content: string) =
  ## Set ``(code, headers, content)`` as the response.
  bind TCActionSend
  result = (TCActionSend, code, none[RawHeaders](), content, true)
  for header in headers:
    setHeader(result[2], header[0], header[1])
  break route


# ========== Header ====================
proc setHeader*(response:Response, headers:Headers):Response =
  for header in headers:
    var index = 0
    var tmpValue = ""
    for i, row in response.headers:
      if row.key == header.key:
        index = i
        tmpValue = row.val
        break
    if tmpValue.len == 0:
      response.headers.add((header.key, header.val))
    else:
      response.headers[index] = (header.key, tmpValue & ", " & header.val)
  return response

# ========== Cookie ====================
proc setCookie*(response:Response, cookie:Cookie):Response =
  for cookieData in cookie.cookies:
    let cookieStr = cookieData.toCookieStr()
    response.headers.add(("Set-cookie", cookieStr))
  return response

# ========== Auth ====================
proc setAuth*(response:Response, auth:Auth):Response =
  ## If not logged in, do nothing.
  ## If logged in but not updated any session value,
  ## expire of session_id is updated.

  if auth.isLogin:
    let sessionId = auth.getToken()
    let cookie = newCookieData("session_id", sessionId,
                      timeForward(SESSION_TIME, Minutes))
                  .toCookieStr()
    response.headers.add(("Set-cookie", cookie))
  return response


proc destroyAuth*(response:Response, auth:Auth):Response =
  if auth.isLogin:
    let sessionId = auth.getToken()
    let cookie = newCookieData("session_id", sessionId, timeForward(-1, Days))
                  .toCookieStr()
    response.headers.add(("Set-cookie", cookie))
  else:
    echoErrorMsg("Tried to destroy auth but not logged in")
  return response



# =============================================================================
proc response*(arg:ResponseData):Response =
  if not arg[4]: raise newException(Error404, "")
  return Response(
    status: arg[1],
    headers: arg[2].get,
    body: arg[3],
    match: arg[4]
  )
  
proc response*(status:HttpCode, body:string): Response =
  return Response(
    status:status,
    bodyString: body,
    responseType: String
  )

proc html*(r_path:string):string =
  ## arg r_path is relative path from /resources/
  block:
    let path = getCurrentDir() & "/resources/" & r_path
    let f = open(path, fmRead)
    result = $(f.readAll)
    defer: f.close()