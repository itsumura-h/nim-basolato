import strutils, times
# framework
import ../../../../../src/basolato/controller
# view
import ../views/pages/sample/cookie_view

proc indexCookie*(request:Request, params:Params):Future[Response] {.async.} =
  var cookie = newCookies(request)
  return render(cookieView(client))

proc storeCookie*(request:Request, params:Params):Future[Response] {.async.} =
  let key = params.getStr("key")
  let value = params.getStr("value")
  var cookie = newCookies(request)
  cookie.add(key, value, httpOnly=false)
  return render(cookieView(client)).setCookie(cookie)

proc updateCookie*(request:Request, params:Params):Future[Response] {.async.} =
  let key = params.getStr("key")
  let days = params.getInt("days")
  var cookie = newCookies(request)
  cookie.updateExpire(key, days, Days)
  return redirect("/sample/cookie").setCookie(cookie)

proc destroyCookie*(request:Request, params:Params):Future[Response] {.async.} =
  let key = params.getStr("key")
  var cookie = newCookies(request)
  cookie.delete(key)
  return redirect("/sample/cookie").setCookie(cookie)
