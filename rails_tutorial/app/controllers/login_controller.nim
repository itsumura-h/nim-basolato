import json, strformat
from strutils import parseInt
# framework
import ../../../src/basolato/controller
import ../../../src/basolato/request_validation
# middleware
import ../../middlewares/custom_validate_middleware
# usecase
import ../../domain/usecases/login_usecase
# view
import ../../resources/login/createHtml

type LoginController* = ref object of Controller

proc newLoginController*(request:Request):LoginController =
  return LoginController.newController(request)


proc create*(this:LoginController):Response =
  return render(createHtml())

proc store*(this:LoginController):Response =
  # request
  let params = this.request.params()
  let email = params["email"]
  let password = params["password"]

  var v = this.request.validate()
  try:
    # validation
    v = v.filled(["email", "password"])
      .length("email", 0, 255)
      .length("password", 6, 1000)
      .password("password")
    if v.errors.len > 0:
      raise newException(Exception, "")
    # business logic
    let userId = newLoginUsecase().login(email, password)
    # response
    this.auth.login()
    return redirect(&"/users/{userId}")
  except:
    # response
    let msg = getCurrentExceptionMsg()
    if msg.len > 0:
      v.errors["exception"] = %[msg]
    let user = %*{"email": email}
    return render(Http500, createHtml(user, v.errors))

proc destroy*(this:LoginController):Response =
  return render("destroy")



proc index*(this:LoginController):Response =
  return render("index")

proc show*(this:LoginController, id:string):Response =
  let id = id.parseInt
  return render("show")

proc edit*(this:LoginController, id:string):Response =
  let id = id.parseInt
  return render("edit")

proc update*(this:LoginController, id:string):Response =
  let id = id.parseInt
  return render("update")

proc destroy*(this:LoginController, id:string):Response =
  let id = id.parseInt
  return render("destroy")
