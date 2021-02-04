import json
# framework
import ../../../../../src/basolato/controller
import ../../../../../src/basolato/request_validation
# view
import ../views/pages/sign/signup_view
import ../views/pages/sign/signin_view
# usecase
import ../../core/usecases/sign_usecase
# repository
import ../../repositories/user/user_rdb_repository


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
    let repository = newUserRdbRepository().toInterface()
    let usecase = newSignUsecase(repository)
    let user = usecase.signUp(name, email, password)
    let auth = await newAuth(request)
    await auth.login()
    await auth.set("id", $(user["id"].getInt))
    await auth.set("name", user["name"].getStr)
    return redirect("/")
  except Exception:
    let params = %*{"name": name, "email": email}
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
    let repository = newUserRdbRepository().toInterface()
    let usecase = newSignUsecase(repository)
    let user = usecase.signIn(email, password)
    let auth = await newAuth(request)
    await auth.login()
    await auth.set("id", $(user["id"].getInt))
    await auth.set("name", user["name"].getStr)
    return redirect("/")
  except:
    let params = %*{"email": email}
    return render(signInView(params, v.errors))


proc signOut*(request:Request, params:Params):Future[Response] {.async.} =
  let auth = await newAuth(request)
  await auth.logout()
  return redirect("/signin")
