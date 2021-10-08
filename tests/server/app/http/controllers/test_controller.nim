import json
import ../../../../../src/basolato/controller
# template
import ../views/pages/test_view


# test controller
proc renderStr*(context:Context, params:Params):Future[Response] {.async.} =
  return render("test")

proc renderHtml*(context:Context, params:Params):Future[Response] {.async.} =
  return render(html("pages/test.html"))

proc renderTemplate*(context:Context, params:Params):Future[Response] {.async.} =
  return render(testView())

proc renderJson*(context:Context, params:Params):Future[Response] {.async.} =
  return render(%*{"key": "test"})

proc status500*(context:Context, params:Params):Future[Response] {.async.} =
  return render(Http500, "")

proc status500json*(context:Context, params:Params):Future[Response] {.async.} =
  return render(Http500, %*{"key": "test"})

proc redirect*(context:Context, params:Params):Future[Response] {.async.} =
  return redirect("/new_url")

proc redirectWithHeader*(context:Context, params:Params):Future[Response] {.async.} =
  let headers = newHttpHeaders()
  headers["key"] = "value"
  return redirect("/new_url", headers)

proc errorRedirect*(context:Context, params:Params):Future[Response] {.async.} =
  return errorRedirect("/new_url")

proc errorRedirectWithHeader*(context:Context, params:Params):Future[Response] {.async.} =
  let headers = newHttpHeaders()
  headers["key"] = "value"
  return errorRedirect("/new_url", headers)

# test helper
proc dd*(context:Context, params:Params):Future[Response] {.async.} =
  var a = %*{
    "key1": "value1",
    "key2": 2
  }
  dd($a, "abc")
  return render("dd")

# test response
proc setHeader*(context:Context, params:Params):Future[Response] {.async.} =
  var header = newHttpHeaders()
  header.add("key1", "value1")
  header.add("key2", ["value1", "value2"])
  return render("setHeader", header)

proc setCookie*(context:Context, params:Params):Future[Response] {.async.} =
  var cookie = Cookies.new(context.request)
  cookie.set("key1", "value1")
  cookie.set("key2", "value2")
  return render("setCookie").setCookie(cookie)

proc setAuth*(context:Context, params:Params):Future[Response] {.async.} =
  await context.set("key1", "value1")
  await context.set("key2", "value2")
  return render("setAuth")

proc destroyAuth*(context:Context, params:Params):Future[Response] {.async.} =
  await context.login()
  let res = await render("setAuth").destroyContext(context)
  return res


# test routing
proc getAction*(context:Context, params:Params):Future[Response] {.async.} =
  return render("get")

proc postAction*(context:Context, params:Params):Future[Response] {.async.} =
  return render("post")

proc patchAction*(context:Context, params:Params):Future[Response] {.async.} =
  return render("patch")

proc putAction*(context:Context, params:Params):Future[Response] {.async.} =
  return render("put")

proc deleteAction*(context:Context, params:Params):Future[Response] {.async.} =
  return render("delete")
