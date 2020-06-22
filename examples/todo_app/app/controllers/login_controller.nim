import json
from strutils import parseInt
import ../../resources/pages/login_view
import ../../resources/pages/signin_view
# framework
import ../../../../src/basolato/controller
import ../../../../src/basolato/request_validation
# usecase
import ../domain/usecases/login_usecase


type LoginController* = ref object of Controller

proc newLoginController*(request:Request):LoginController =
  return LoginController.newController(request)


proc loginPage*(this:LoginController):Response =
  return render(this.view.loginView())

proc signinPage*(this:LoginController):Response =
  return render(this.view.signinView())

proc signin*(this:LoginController):Response =
  # params
  let params = this.request.params()
  let name = params["name"]
  let email = params["email"]
  let password = params["password"]

  var v = this.request.newValidation()
  try:
    # validation
    v.required(["name", "email", "password"])
    v.password("password")
    v.strictEmail("email")
    v.valid()
    # bussines logic
    newLoginUsecase().signin(name, email, password)
    # response
    return redirect("/signin")
  except ValidationError:
    return render(Http422, this.view.signinView(%params, v.errors))
  except:
    v.errors["exception"] = %getCurrentExceptionMsg()
    return render(Http500, this.view.signinView(%params, v.errors))


proc index*(this:LoginController):Response =
  return render("index")

proc show*(this:LoginController, id:string):Response =
  let id = id.parseInt
  return render("show")

proc create*(this:LoginController):Response =
  return render("create")

proc store*(this:LoginController):Response =
  return render("store")

proc edit*(this:LoginController, id:string):Response =
  let id = id.parseInt
  return render("edit")

proc update*(this:LoginController, id:string):Response =
  let id = id.parseInt
  return render("update")

proc destroy*(this:LoginController, id:string):Response =
  let id = id.parseInt
  return render("destroy")
