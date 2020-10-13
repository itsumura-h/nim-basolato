import json
import ../../../../src/basolato/controller
import ../../../../src/basolato/security
# template
import ../../resources/pages/test_view


type TestController = ref object of Controller
  name*:string

proc newTestController*(request:Request):TestController =
  var testController = TestController.newController(request)
  testController.name = "test"
  return testController

# test controller
proc renderStr*(this:TestController):Response =
  return render("test")

proc renderHtml*(this:TestController):Response =
  return render(html("pages/test.html"))

proc renderTemplate*(this:TestController):Response =
  return render(this.view.testView())

proc renderJson*(this:TestController):Response =
  return render(%*{"key": "test"})

proc status500*(this:TestController):Response =
  return render(Http500, "")

proc status500json*(this:TestController):Response =
  return render(Http500, %*{"key": "test"})

proc redirect*(this:TestController):Response =
  return redirect("/new_url")

proc error_redirect*(this:TestController):Response =
  return errorRedirect("/new_url")

# test helper
proc dd*(this:TestController):Response =
  var a = %*{
    "key1": "value1",
    "key2": 2
  }
  dd($a, "abc")
  return render("dd")

# test response
proc setHeader*(this:TestController):Response =
  var header = newHeaders()
  header.set("key1", "value1")
  header.set("key2", ["value1", "value2"])
  return render("setHeader", header)

proc setCookie*(this:TestController):Response =
  var cookie = newCookie(this.request)
  cookie.set("key1", "value1")
  cookie.set("key2", "value2")
  return render("setCookie").setCookie(cookie)

proc setAuth*(this:TestController):Response =
  this.auth.login()
  this.auth.set("key1", "value1")
  this.auth.set("key2", "value2")
  return render("setAuth").setAuth(this.auth)

proc destroyAuth*(this:TestController):Response =
  this.auth.login()
  return render("setAuth").destroyAuth(this.auth)


# test routing
proc getAction*(this:TestController):Response =
  return render("get")

proc postAction*(this:TestController):Response =
  return render("post")

proc patchAction*(this:TestController):Response =
  return render("patch")

proc putAction*(this:TestController):Response =
  return render("put")

proc deleteAction*(this:TestController):Response =
  return render("delete")