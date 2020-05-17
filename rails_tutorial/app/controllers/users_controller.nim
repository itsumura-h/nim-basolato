import json, strformat
from strutils import parseInt
# framework
import ../../../src/basolato/controller
import ../../../src/basolato/request_validation
# middleware
import ../../middlewares/custom_validate_middleware
# usecase
import ../../domain/usecases/users_usecase
# view
import ../../resources/users/create
import ../../resources/users/show

type UsersController* = ref object of Controller

proc newUsersController*(request:Request):UsersController =
  return UsersController.newController(request)


proc index*(this:UsersController):Response =
  return render("index")

proc show*(this:UsersController, id:string):Response =
  # validation
  let v = Validation()
  if not v.isInt(id):
    return render(Http404, "")
  # request
  let id = id.parseInt
  # business logic
  let user = newUsersUsecase().show(id)
  # flash
  let flash = this.auth.getFlash()
  # response
  if user.kind == JNull:
    return render(Http404, "")
  return render(this.view.showHtml(user, flash))

proc create*(this:UsersController):Response =
  return render(this.view.createHtml())

proc store*(this:UsersController):Response =
  # request
  let params = this.request.params()
  let name = params["name"]
  let email = params["email"]
  let password = params["password"]

  var v = this.request.validate()
  try:
    # validation
    v = v.filled(["name", "email", "password", "password_confirm"])
      .length("name", 0, 50)
      .length("email", 0, 255)
      .length("password", 6, 1000)
      .password("password")
      .equalInput("password", "password_confirm")
    if v.errors.len > 0:
      raise newException(Exception, "")
    # business logic
    let userId = newUsersUsecase().store(name=name, email=email, password=password)
    # auth
    this.auth.login()
    this.auth.set("id", $userId)
    this.auth.set("name", name)
    # flash
    this.auth.setFlash("success", "Welcome to the Sample App!")
    # response
    return redirect( &"/users/{userId}" )
  except:
    # response
    let msg = getCurrentExceptionMsg()
    if msg.len > 0:
      v.errors["exception"] = %[msg]
    let user = %*{"name": name, "email": email}
    return render(Http500, this.view.createHtml(user, v.errors))

proc edit*(this:UsersController, id:string):Response =
  let id = id.parseInt
  return render("edit")

proc update*(this:UsersController, id:string):Response =
  let id = id.parseInt
  return render("update")

proc destroy*(this:UsersController, id:string):Response =
  let id = id.parseInt
  return render("destroy")
