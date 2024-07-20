import std/asyncdispatch
import std/json
import std/strutils
import std/tables
import std/times
# framework
import ../../../../../src/basolato/controller
# view
import ../views/presenters/app_presenter
import ../views/layouts/app/app_layout
import ../views/pages/cookie/cookie_page


proc index*(context:Context):Future[Response] {.async.} =
  const title = "Cookie"
  let appPresenter = AppPresenter.new()
  let appLayoutModel = appPresenter.invoke(title)

  let cookies = %(Cookies.new(context.request).getAll())
  let page = cookiePage(cookies)

  let view = appLayout(appLayoutModel, page)
  return render(view)


proc store*(context:Context):Future[Response] {.async.} =
  let key = context.params.getStr("key")
  let value = context.params.getStr("value")
  if key.len == 0:
    return redirect("/sample/cookie")
  var cookie = Cookies.new(context.request)
  cookie.set(key, value)
  return redirect("/sample/cookie").setCookie(cookie)


proc update*(context:Context):Future[Response] {.async.} =
  let key = context.params.getStr("key")
  let days = context.params.getInt("days")
  var cookies = Cookies.new(context.request)
  let val = cookies.get(key)
  cookies.set(key, val, timeForward(days, Days))
  return redirect("/sample/cookie").setCookie(cookies)


proc delete*(context:Context):Future[Response] {.async.} =
  let key = context.params.getStr("key")
  var cookie = Cookies.new(context.request)
  cookie.delete(key)
  return redirect("/sample/cookie").setCookie(cookie)


proc destroy*(context:Context):Future[Response] {.async.} =
  var cookie = Cookies.new(context.request)
  cookie.destroy()
  return redirect("/sample/cookie").setCookie(cookie)
