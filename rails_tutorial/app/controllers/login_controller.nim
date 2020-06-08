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
import ../../resources/login/create

type LoginController* = ref object of Controller

proc newLoginController*(request:Request):LoginController =
  return LoginController.newController(request)


proc create*(this:LoginController):Response =
  return render(this.view.createHtml())

proc store*(this:LoginController):Response =
  # request
  let params = this.request.params()
  let email = params["email"]
  let password = params["password"]

  var v = this.request.validate()
  try:
    # validation
    v = v.filled(["email", "password"])
      .length("email", 1, 255)
      .length("password", 6, 1000)
      .password("password")
    if v.errors.len > 0:
      raise newException(Exception, "")
    # business logic
    let user = newLoginUsecase().login(email, password)
    # auth
    let userId = user["id"].getInt()
    let userName = user["name"].getStr()
    this.auth = newAuth()
    this.auth.login()
    this.auth.set("id", $userId)
    this.auth.set("name", userName)
    this.auth.setFlash("success", "Success to login")
    # response
    if params.hasKey("redirect"):
      let url = params["redirect"]
      return redirect(url).setAuth(this.auth)
    else:
      return redirect(&"/users/{userId}").setAuth(this.auth)
  except:
    # response
    let msg = getCurrentExceptionMsg()
    if msg.len > 0:
      v.errors["exception"] = %[msg]
    let user = %*{"email": email}
    return render(Http500, this.view.createHtml(user, v.errors))

proc destroy*(this:LoginController):Response =
  return redirect("/").destroyAuth(this.auth)



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
