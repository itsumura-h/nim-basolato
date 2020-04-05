import json
from strutils import parseInt
# framework
import basolato/controller
# entity
import ../../domain/entities/users_entity
# repository
import ../../domain/repositories/users_repository
# view
import ../views/users_view

type UsersController* = ref object of Controller

proc newUsersController*(request:Request):UsersController =
  return UsersController.newController(request)


proc index*(this:UsersController):Response =
  return render("index")

proc show*(this:UsersController, id:string):Response =
  block:
    let id = id.parseInt
    let userData = usersShowRepository(id)
    return render(usersShowView(userData))

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
