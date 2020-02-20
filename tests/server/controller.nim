import ../../src/basolato/controller

type TestController = ref object of Controller
  name*:string

proc newTestController*(request:Request):TestController =
  var testController = TestController.newController(request)
  testController.name = "test"
  return testController

proc renderStr*(this:TestController):Response =
  return render("test")