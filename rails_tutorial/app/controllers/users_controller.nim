import json
from strutils import parseInt
# framework
import basolato/controller
import basolato/validation
# service
import ../../domain/user/user_service
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
  let user = newUserService().show(id)
  # response
  if user.kind == JNull:
    return render(Http404, "")
  return render(showHtml(user))

proc create*(this:UsersController):Response =
  return render(createHtml())

proc store*(this:UsersController):Response =
  # request
  let name = this.request.params["name"]
  let email = this.request.params["email"]
  let password = this.request.params["password"]
  let password_confirm = this.request.params["password_confirm"]
  let user = %*{"name": name, "email": email}
  var errors = newSeq[string]()
  try:
    # validation
    if password != password_confirm:
      raise newException(Exception, "password is not match")
    # business logig
    newUserService().store(name=name, email=email, password=password)
    # response
    return redirect("/users")
  except:
    # response
    errors.add(getCurrentExceptionMsg())
    return render(Http500, createHtml(user, errors))

proc edit*(this:UsersController, id:string):Response =
  let id = id.parseInt
  return render("edit")

proc update*(this:UsersController, id:string):Response =
  let id = id.parseInt
  return render("update")

proc destroy*(this:UsersController, id:string):Response =
  let id = id.parseInt
  return render("destroy")
