import json
# framework
import ../../../../src/basolato/controller
import ../../../../src/basolato/request_validation
# view
import ../../resources/pages/sign/signup_view
import ../../resources/pages/sign/signin_view
# usecase
import ../domain/usecases/sign_usecase


proc signUpPage*(request:Request, params:Params):Future[Response] {.async.} =
  return render(signupView())

proc signUp*(request:Request, params:Params):Future[Response] {.async.} =
  let name = params.getStr("name")
  let email = params.getStr("email")
  let password = params.getStr("password")
  var v = newValidation(params)
  v.required(["name", "email", "password"])
  v.strictEmail("email")
  v.password("password")
  try:
    v.valid()
    let usecase = newSignUsecase()
    let user = usecase.signUp(name, email, password)
    let auth = newAuth()
    auth.login()
    auth.set("id", $(user["id"].getInt))
    auth.set("name", user["name"].getStr)
    return redirect("/").setAuth(auth)
  except Exception:
    let params = {"name": name, "email": email}.newTable
    return render(signupView(params, v.errors))


proc deleteAccountPage*(request:Request, params:Params):Future[Response] {.async.} =
  return render("delete account")

proc deleteAccount*(request:Request, params:Params):Future[Response] {.async.} =
  return render("delete account")

proc signInPage*(request:Request, params:Params):Future[Response] {.async.} =
  return render(signinView())

proc signIn*(request:Request, params:Params):Future[Response] {.async.} =
  let email = params.getStr("email")
  let password = params.getStr("password")
  var v = newValidation(params)
  v.required(["email", "password"])
  v.strictEmail("email")
  v.password("password")
  try:
    let usecase = newSignUsecase()
    let user = usecase.signIn(email, password)
    let auth = newAuth()
    auth.login()
    auth.set("id", $(user["id"].getInt))
    auth.set("name", user["name"].getStr)
    return redirect("/").setAuth(auth)
  except:
    let params = {"email": email}.newTable
    return render(signInView(params, v.errors))


proc signOut*(request:Request, params:Params):Future[Response] {.async.} =
  let auth = newAuth(request)
  return redirect("/signin").destroyAuth(auth)


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
