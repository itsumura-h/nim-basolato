import json
import ../../../../src/basolato/controller
import ../../../../src/basolato/core/security
# template
import ../../resources/pages/test_view


# test controller
proc renderStr*(request:Request, params:Params):Future[Response] {.async.} =
  return render("test")

proc renderHtml*(request:Request, params:Params):Future[Response] {.async.} =
  return render(html("pages/test.html"))

proc renderTemplate*(request:Request, params:Params):Future[Response] {.async.} =
  return render(testView())

proc renderJson*(request:Request, params:Params):Future[Response] {.async.} =
  return render(%*{"key": "test"})

proc status500*(request:Request, params:Params):Future[Response] {.async.} =
  return render(Http500, "")

proc status500json*(request:Request, params:Params):Future[Response] {.async.} =
  return render(Http500, %*{"key": "test"})

proc redirect*(request:Request, params:Params):Future[Response] {.async.} =
  return redirect("/new_url")

proc error_redirect*(request:Request, params:Params):Future[Response] {.async.} =
  return errorRedirect("/new_url")

# test helper
proc dd*(request:Request, params:Params):Future[Response] {.async.} =
  var a = %*{
    "key1": "value1",
    "key2": 2
  }
  dd($a, "abc")
  return render("dd")

# test response
proc setHeader*(request:Request, params:Params):Future[Response] {.async.} =
  var header = newHeaders()
  header.set("key1", "value1")
  header.set("key2", ["value1", "value2"])
  return render("setHeader", header)

proc setCookie*(request:Request, params:Params):Future[Response] {.async.} =
  var cookie = newCookie(request)
  cookie.set("key1", "value1")
  cookie.set("key2", "value2")
  return render("setCookie").setCookie(cookie)

proc setAuth*(request:Request, params:Params):Future[Response] {.async.} =
  let auth = await newAuth(request)
  await auth.set("key1", "value1")
  await auth.set("key2", "value2")
  return render("setAuth")

proc destroyAuth*(request:Request, params:Params):Future[Response] {.async.} =
  let auth = await newAuth(request)
  await auth.login()
  await auth.destroy()
  return render("setAuth")


# test routing
proc getAction*(request:Request, params:Params):Future[Response] {.async.} =
  return render("get")

proc postAction*(request:Request, params:Params):Future[Response] {.async.} =
  return render("post")

proc patchAction*(request:Request, params:Params):Future[Response] {.async.} =
  return render("patch")

proc putAction*(request:Request, params:Params):Future[Response] {.async.} =
  return render("put")

proc deleteAction*(request:Request, params:Params):Future[Response] {.async.} =
  return render("delete")