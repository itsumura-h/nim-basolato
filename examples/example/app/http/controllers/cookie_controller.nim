import strutils, times
# framework
import ../../../../../src/basolato/controller
# view
import ../views/pages/sample/cookie_view

proc indexCookie*(request:Request, params:Params):Future[Response] {.async.} =
  let auth = await newAuth(request)
  return render(cookieView(auth))

proc storeCookie*(request:Request, params:Params):Future[Response] {.async.} =
  let auth = await newAuth(request)
  let key = params.getStr("key")
  let value = params.getStr("value")
  var cookie = newCookie(request)
  cookie.set(key, value)
  return render(cookieView(auth)).setCookie(cookie)

proc updateCookie*(request:Request, params:Params):Future[Response] {.async.} =
  let key = params.getStr("key")
  let days = params.getInt("days")
  var cookie = newCookie(request)
  cookie.updateExpire(key, days, Days)
  return redirect("/sample/cookie").setCookie(cookie)

proc destroyCookie*(request:Request, params:Params):Future[Response] {.async.} =
  let key = params.getStr("key")
  var cookie = newCookie(request)
  cookie.delete(key)
  return redirect("/sample/cookie").setCookie(cookie)

proc destroyCookies*(request:Request, params:Params):Future[Response] {.async.} =
  var cookie = newCookie(request)
  cookie.destroy()
  return redirect("/sample/cookie").setCookie(cookie)
