import json
from strutils import parseInt
# framework
import ../../../../src/basolato/controller
import ../../../../src/basolato/request_validation
# middleware
import ../middlewares/controller_middlewares
# usecase
import ../domain/usecases/login_usecase
# view
import ../../resources/pages/login_view
import ../../resources/pages/signin_view


type LoginController* = ref object of Controller

proc newLoginController*(request:Request):LoginController =
  redirectIfLogedIn(request)
  return LoginController.newController(request)


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
    let userId = newLoginUsecase().signin(name, email, password)
    let auth = newAuth()
    auth.login()
    auth.set("user_id", $user_id)
    # response
    return redirect("/").setAuth(auth)
  except ValidationError:
    return render(Http422, this.view.signinView(%params, v.errors))
  except:
    v.errors["exception"] = %getCurrentExceptionMsg()
    return render(Http500, this.view.signinView(%params, v.errors))

proc loginPage*(this:LoginController):Response =
  return render(this.view.loginView())

proc login*(this:LoginController):Response =
  #params
  let params = this.request.params()
  let email = params["email"]
  let password = params["password"]

  var v = this.request.newValidation()
  try:
    # validation
    v.required(["email", "password"])
    v.email("email")
    v.valid()
    # bussiness logic
    let userId = newLoginUsecase().login(email, password)
    # auth
    let auth = newAuth()
    auth.login()
    auth.set("id", $userId)
    return redirect("/").setAuth(auth)
  except ValidationError, CatchableError:
    return render(Http412, this.view.loginView(%params, v.errors))
  except:
    v.errors["exception"] = %getCurrentExceptionMsg()
    return render(Http500, this.view.loginView(%params, v.errors))

proc logout*(this:LoginController):Response =
  let auth = this.request.newAuth()
  if not auth.isLogin():
    return redirect("/")
  auth.logout()
  return redirect("/").setAuth(auth)


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
