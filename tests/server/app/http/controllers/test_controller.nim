import std/asyncdispatch
import std/json
import std/httpcore
import ../../../../../src/basolato/controller
# template
import ../views/pages/test_view


# test controller
proc renderStr*(context:Context):Future[Response] {.async.} =
  return render("test")

proc renderHtml*(context:Context):Future[Response] {.async.} =
  return render(html("pages/test.html"))

proc renderTemplate*(context:Context):Future[Response] {.async.} =
  return render(testView())

proc renderJson*(context:Context):Future[Response] {.async.} =
  return render(%*{"key": "test"})

proc status500*(context:Context):Future[Response] {.async.} =
  return render(Http500, "")

proc status500json*(context:Context):Future[Response] {.async.} =
  return render(Http500, %*{"key": "test"})

proc redirect*(context:Context):Future[Response] {.async.} =
  return redirect("/new_url")

proc redirectWithHeader*(context:Context):Future[Response] {.async.} =
  let headers = newHttpHeaders()
  headers["key"] = "value"
  return redirect("/new_url", headers)

proc errorRedirect*(context:Context):Future[Response] {.async.} =
  return errorRedirect("/new_url")

proc errorRedirectWithHeader*(context:Context):Future[Response] {.async.} =
  let headers = newHttpHeaders()
  headers["key"] = "value"
  return errorRedirect("/new_url", headers)

# test helper
proc dd*(context:Context):Future[Response] {.async.} =
  var a = %*{
    "key1": "value1",
    "key2": 2
  }
  dd($a, "abc")
  return render("dd")

# test response
proc setHeader*(context:Context):Future[Response] {.async.} =
  var header = newHttpHeaders()
  header.add("key1", "value1")
  header.add("key2", ["value1", "value2"])
  return render("setHeader", header)

proc setCookie*(context:Context):Future[Response] {.async.} =
  var cookies = Cookies.new(context.request)
  cookies.set("key1", "value1")
  cookies.set("key2", "value2")
  return render("setCookie").setCookie(cookies)

proc setAuth*(context:Context):Future[Response] {.async.} =
  await context.set("key1", "value1")
  await context.set("key2", "value2")
  return render("setAuth")

proc destroyAuth*(context:Context):Future[Response] {.async.} =
  await context.login()
  let res = await render("setAuth").destroyContext(context)
  return res


# test routing
proc getAction*(context:Context):Future[Response] {.async.} =
  return render("get")

proc postAction*(context:Context):Future[Response] {.async.} =
  let status = context.params.getStr("status")
  if status == "invalid":
    return render("invalid status")
  return render("post")

proc patchAction*(context:Context):Future[Response] {.async.} =
  return render("patch")

proc putAction*(context:Context):Future[Response] {.async.} =
  return render("put")

proc deleteAction*(context:Context):Future[Response] {.async.} =
  return render("delete")

# csrf token
proc getCsrf*(context:Context):Future[Response] {.async.} =
  return render(testView())
