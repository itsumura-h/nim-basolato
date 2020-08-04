import json
from strutils import parseInt
# framework
import ../../../../src/basolato/controller
# usecase
import ../domain/usecases/login_usecase

type ApiLoginController* = ref object of Controller

proc newApiLoginController*(request:Request):ApiLoginController =
  return ApiLoginController.newController(request)

proc login*(this:ApiLoginController):Response =
  #params
  let params = this.request.body.parseJson()
  let email = params["email"].getStr
  let password = params["password"].getStr
  try:
    # bussiness logic
    let userData = newLoginUsecase().login(email, password)
    # auth
    this.auth.login()
    this.auth.set("user_id", $userData["id"].getInt)
    this.auth.set("name", userData["name"].getStr)
    return render(%*{"csrf_token": newCsrfToken().getToken()}).setAuth(this.auth)
  except CatchableError:
    return render(Http412, %*{"errors": getCurrentExceptionMsg()})
  except:
    return render(Http500, %*{"errors": getCurrentExceptionMsg()})

proc logout*(this:ApiLoginController):Response =
  this.auth.logout()
  return render(%*{"message": "logout"}).setAuth(this.auth)

proc index*(this:ApiLoginController):Response =
  return render("index")

proc show*(this:ApiLoginController, id:string):Response =
  let id = id.parseInt
  return render("show")

proc create*(this:ApiLoginController):Response =
  return render("create")

proc store*(this:ApiLoginController):Response =
  return render("store")

proc edit*(this:ApiLoginController, id:string):Response =
  let id = id.parseInt
  return render("edit")

proc update*(this:ApiLoginController, id:string):Response =
  let id = id.parseInt
  return render("update")

proc destroy*(this:ApiLoginController, id:string):Response =
  let id = id.parseInt
  return render("destroy")
