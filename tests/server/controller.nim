import json
import ../../src/basolato/controller
import ../../src/basolato/security
# template
import resources/test_template

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
  return render(html("test.html"))

proc renderTemplate*(this:TestController):Response =
  return render(test_template())

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

# test response
proc setHeader*(this:TestController):Response =
  var header = newHeaders()
                .set("key1", "value1")
                .set("key2", ["value1", "value2"])
  return render("setHeader").setHeader(header)

proc setCookie*(this:TestController):Response =
  var cookie = newCookie(this.request)
                .set("key1", "value1")
                .set("key2", "value2")
  return render("setCookie").setCookie(cookie)

proc setAuth*(this:TestController):Response =
  var auth = newAuth()
              .set("key1", "value1")
              .set("key2", "value2")
  return render("setAuth").setAuth(auth)

proc destroyAuth*(this:TestController):Response =
  let auth = newAuth()
  return render("setAuth").destroyAuth(auth)


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