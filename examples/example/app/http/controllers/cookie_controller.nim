import strutils, times, json
# framework
import ../../../../../src/basolato/controller
# view
import ../views/pages/sample/cookie_view


proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let cookies = %Cookies.new(context.request).getAll()
  return render(await cookieView(cookies))

proc store*(context:Context, params:Params):Future[Response] {.async.} =
  let key = params.getStr("key")
  let value = params.getStr("value")
  if key.len == 0:
    return redirect("/sample/cookie")
  var cookie = Cookies.new(context.request)
  cookie.set(key, value)
  return redirect("/sample/cookie").setCookie(cookie)

proc update*(context:Context, params:Params):Future[Response] {.async.} =
  let key = params.getStr("key")
  let days = params.getInt("days")
  var cookies = Cookies.new(context.request)
  let val = cookies.get(key)
  cookies.set(key, val, timeForward(days, Days))
  return redirect("/sample/cookie").setCookie(cookies)

proc delete*(context:Context, params:Params):Future[Response] {.async.} =
  let key = params.getStr("key")
  var cookie = Cookies.new(context.request)
  cookie.delete(key)
  return redirect("/sample/cookie").setCookie(cookie)

proc destroy*(context:Context, params:Params):Future[Response] {.async.} =
  var cookie = Cookies.new(context.request)
  cookie.destroy()
  return redirect("/sample/cookie").setCookie(cookie)
