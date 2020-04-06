import json
from strutils import parseInt
# framework
import basolato/controller
# services
import ../../domain/services/users_service
# view
import ../views/users_view

type UsersController* = ref object of Controller

proc newUsersController*(request:Request):UsersController =
  return UsersController.newController(request)


proc index*(this:UsersController):Response =
  return render("index")

proc show*(this:UsersController, id:string):Response =
  let id = id.parseInt
  let user = newUserService().show(id)
  if user.kind == JNull:
    raise newException(Error404, "")
  return render(usersShowView(user))

proc create*(this:UsersController):Response =
  return render(usersCreateView())

proc store*(this:UsersController):Response =
  return render("store")

proc edit*(this:UsersController, id:string):Response =
  block:
    let id = id.parseInt
    return render("edit")

proc update*(this:UsersController, id:string):Response =
  block:
    let id = id.parseInt
    return render("update")

proc destroy*(this:UsersController, id:string):Response =
  block:
    let id = id.parseInt
    return render("destroy")
