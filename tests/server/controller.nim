import json
import ../../src/basolato/controller
# template
import resources/test_template

type TestController = ref object of Controller
  name*:string

proc newTestController*(request:Request):TestController =
  var testController = TestController.newController(request)
  testController.name = "test"
  return testController

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
