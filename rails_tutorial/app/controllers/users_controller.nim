from strutils import parseInt
# framework
import basolato/controller
# view
import ../../resources/users/create


type UsersController* = ref object of Controller

proc newUsersController*(request:Request):UsersController =
  return UsersController.newController(request)


proc index*(this:UsersController):Response =
  return render("index")

proc show*(this:UsersController, id:string):Response =
  block:
    let id = id.parseInt
    return render("show")

proc create*(this:UsersController):Response =
  # return render("create")
  return render(createHtml())

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
