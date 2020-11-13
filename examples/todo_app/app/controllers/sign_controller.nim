import json
# framework
import ../../../../src/basolato/controller
import ../../../../src/basolato/request_validation
# view
import ../../resources/pages/sign/signup_view
import ../../resources/pages/sign/signin_view
# usecase
import ../domain/usecases/sign_usecase


proc signup_page*(request:Request, params:Params):Future[Response] {.async.} =
  return render(signupView())

proc signup*(request:Request, params:Params):Future[Response] {.async.} =
  let name = params.requestParams.getStr("name")
  let email = params.requestParams.getStr("email")
  let password = params.requestParams.getStr("password")
  var v = newValidation(params.requestParams)
  v.required(["name", "email", "password"])
  v.strictEmail("email")
  v.password("password")
  try:
    v.valid()
    let usecase = newSignUsecase()
    usecase.signIn(name, email, password)
    let auth = newAuth()
    auth.set("name", name)
    auth.login()
    return redirect("/").setAuth(auth)
  except Exception:
    let params = {"name": name, "email": email}.newTable
    echo v.errors
    return render(signupView(params, v.errors))


proc delete_account_page*(request:Request, params:Params):Future[Response] {.async.} =
  return render("delete account")

proc delete_account*(request:Request, params:Params):Future[Response] {.async.} =
  return render("delete account")

proc signin_page*(request:Request, params:Params):Future[Response] {.async.} =
  return render(signinView())

proc signin*(request:Request, params:Params):Future[Response] {.async.} =
  return render("signin")

proc signout*(request:Request, params:Params):Future[Response] {.async.} =
  return render("signout")



# proc index*(request:Request, params:Params):Future[Response] {.async.} =
#   return render("index")

# proc show*(request:Request, params:Params):Future[Response] {.async.} =
#   let id = params.urlParams["id"].getInt
#   return render("show")

# proc create*(request:Request, params:Params):Future[Response] {.async.} =
#   return render("create")

# proc store*(request:Request, params:Params):Future[Response] {.async.} =
#   return render("store")

# proc edit*(request:Request, params:Params):Future[Response] {.async.} =
#   let id = params.urlParams["id"].getInt
#   return render("edit")

# proc update*(request:Request, params:Params):Future[Response] {.async.} =
#   let id = params.urlParams["id"].getInt
#   return render("update")

# proc destroy*(request:Request, params:Params):Future[Response] {.async.} =
#   let id = params.urlParams["id"].getInt
#   return render("destroy")
