import strutils, times
# framework
import ../../../../src/basolato_httpbeast/controller
# view
import ../../resources/pages/sample/cookie

proc indexCookie*(request:Request, params:Params):Future[Response] {.async.} =
  let auth = newAuth(request)
  return render(cookieVIew(auth))

proc storeCookie*(request:Request, params:Params):Future[Response] {.async.} =
  let auth = newAuth(request)
  let key = params.requestParams.get("key")
  let value = params.requestParams.get("value")
  var cookie = newCookie(request)
  cookie.set(key, value)
  return render(cookieVIew(auth)).setCookie(cookie)

proc updateCookie*(request:Request, params:Params):Future[Response] {.async.} =
  let key = params.requestParams.get("key")
  let days = params.requestParams.get("days").parseInt
  var cookie = newCookie(request)
  cookie.updateExpire(key, days, Days)
  return redirect("/sample/cookie").setCookie(cookie)

proc destroyCookie*(request:Request, params:Params):Future[Response] {.async.} =
  let key = params.requestParams.get("key")
  var cookie = newCookie(request)
  cookie.delete(key)
  return redirect("/sample/cookie").setCookie(cookie)

proc destroyCookies*(request:Request, params:Params):Future[Response] {.async.} =
  var cookie = newCookie(request)
  cookie.destroy()
  return redirect("/sample/cookie").setCookie(cookie)
