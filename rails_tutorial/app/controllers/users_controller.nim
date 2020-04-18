import json, strformat
from strutils import parseInt
# framework
import ../../../src/basolato/controller
# import ../../../src/basolato/security
# import basolato/validation
import ../../../src/basolato/request_validation
# middleware
import ../../middlewares/custom_validate_middleware
# service
import ../../domain/user/user_service
# view
import ../../resources/users/create
import ../../resources/users/show

type UsersController* = ref object of Controller

proc newUsersController*(request:Request):UsersController =
  let c = UsersController.newController(request)
  c.auth = newAuth(request)
  return c

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
  let user = newUserService().show(id)
  # flash
  if this.auth.some("flash_success"):
    let flash = %*{"success": this.auth.get("flash_success")}
    let auth = this.auth.delete("flash_success")
    return render(showHtml(user, flash=flash)).setAuth(auth)
  else:
    # response
    if user.kind == JNull:
      return render(Http404, "")
    return render(showHtml(user))

proc create*(this:UsersController):Response =
  return render(createHtml())

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
    # business logic
    if v.errors.len > 0:
      raise newException(Exception, "")
    let userId = newUserService().store(name=name, email=email, password=password)
    # flash
    let auth = newAuth()
      .set("name", name)
      .set("flash_success", "Welcome to the Sample App!")
    # response
    return redirect( &"/users/{userId}" ).setAuth(auth)
  except:
    # response
    v.errors["exception"] = %[getCurrentExceptionMsg()]
    let user = %*{"name": name, "email": email}
    return render(Http500, createHtml(user, v.errors))

proc edit*(this:UsersController, id:string):Response =
  let id = id.parseInt
  return render("edit")

proc update*(this:UsersController, id:string):Response =
  let id = id.parseInt
  return render("update")

proc destroy*(this:UsersController, id:string):Response =
  let id = id.parseInt
  return render("destroy")
