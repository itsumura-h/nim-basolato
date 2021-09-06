import strutils, times, json
# framework
import ../../../../../src/basolato/controller
import ../../../../../src/basolato/core/security/cookie
# view
import ../views/pages/sample/cookie_view


proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let cookies = %newCookies(context.request).getAll()
  return render(cookieView(cookies))

proc store*(context:Context, params:Params):Future[Response] {.async.} =
  let key = params.getStr("key")
  let value = params.getStr("value")
  var cookie = newCookies(context.request)
  cookie.set(key, value)
  return redirect("/sample/cookie").setCookie(cookie)

proc update*(context:Context, params:Params):Future[Response] {.async.} =
  let key = params.getStr("key")
  let days = params.getInt("days")
  var cookies = newCookies(context.request)
  let val = cookies.get(key)
  cookies.set(key, val, timeForward(days, Days))
  return redirect("/sample/cookie").setCookie(cookies)

proc delete*(context:Context, params:Params):Future[Response] {.async.} =
  let key = params.getStr("key")
  var cookie = newCookies(context.request)
  cookie.delete(key)
  return redirect("/sample/cookie").setCookie(cookie)

proc destroy*(context:Context, params:Params):Future[Response] {.async.} =
  var cookie = newCookies(context.request)
  cookie.destroy()
  return redirect("/sample/cookie").setCookie(cookie)
