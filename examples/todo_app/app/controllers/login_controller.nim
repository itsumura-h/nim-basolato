from strutils import parseInt
import ../../resources/pages/login_view
# framework
import ../../../../src/basolato/controller


type LoginController* = ref object of Controller

proc newLoginController*(request:Request):LoginController =
  return LoginController.newController(request)


proc index*(this:LoginController):Response =
  return render(this.view.loginView())

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
