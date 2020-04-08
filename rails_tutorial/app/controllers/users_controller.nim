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
  return render("store")

proc edit*(this:UsersController, id:string):Response =
  let id = id.parseInt
  return render("edit")

proc update*(this:UsersController, id:string):Response =
  let id = id.parseInt
  return render("update")

proc destroy*(this:UsersController, id:string):Response =
  let id = id.parseInt
  return render("destroy")
