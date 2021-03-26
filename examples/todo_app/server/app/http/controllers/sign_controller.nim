import json
# framework
import ../../../../../../src/basolato/controller
import ../../../../../../src/basolato/request_validation
# view
import ../views/pages/sign/signup_view
import ../views/pages/sign/signin_view
# usecase
import ../../core/usecases/sign_usecase
# repository
import ../../repositories/user/user_rdb_repository


proc signUpPage*(request:Request, params:Params):Future[Response] {.async.} =
  let auth = await newAuth(request)
  return await render(signupView(params)).setAuth(auth)

proc signUp*(request:Request, params:Params):Future[Response] {.async.} =
  let name = params.getStr("name")
  let email = params.getStr("email")
  let password = params.getStr("password")
  params.required(["name", "email", "password"])
  params.email("email")
  params.password("password")
  if params.hasErrors:
    return render(signupView(params))
  try:
    let repository = newUserRdbRepository().toInterface()
    let usecase = newSignUsecase(repository)
    let user = usecase.signUp(name, email, password)
    let auth = await newAuth(request)
    await auth.login()
    await auth.set("id", $(user["id"].getInt))
    await auth.set("name", user["name"].getStr)
    return redirect("/")
  except Exception:
    return render(signupView(params))


proc deleteAccountPage*(request:Request, params:Params):Future[Response] {.async.} =
  return render("delete account")

proc deleteAccount*(request:Request, params:Params):Future[Response] {.async.} =
  return render("delete account")

proc signInPage*(request:Request, params:Params):Future[Response] {.async.} =
  let auth = await newAuth(request)
  return await render(signinView(params)).setAuth(auth)

proc signIn*(request:Request, params:Params):Future[Response] {.async.} =
  let email = params.getStr("email")
  let password = params.getStr("password")
  params.required("email"); params.required("password")
  params.email("email")
  if params.hasErrors:
    return render(signInView(params))
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
    return render(signInView(params))


proc signOut*(request:Request, params:Params):Future[Response] {.async.} =
  let auth = await newAuth(request)
  await auth.logout()
  return redirect("/signin")

# ==================== API ====================

proc signInApi*(request:Request, params:Params):Future[Response] {.async.} =
  params.required(["email", "password"])
  params.email("email")
  params.password("password")
  if params.hasErrors:
    return render(Http400, %*params.errors)

  let email = params.getStr("email")
  let password = params.getStr("password")
  try:
    let repository = newUserRdbRepository().toInterface()
    let usecase = newSignUsecase(repository)
    let user = usecase.signIn(email, password)
    let auth = await newAuth(request)
    await auth.login()
    await auth.set("id", $(user["id"].getInt))
    await auth.set("name", user["name"].getStr)
    return await render(Http200, newJObject()).setAuth(auth)
  except:
    let params = %*{"email": email}
    return render(Http400, %*{"params":params, "error": getCurrentExceptionMsg()})

proc signOutApi*(request:Request, params:Params):Future[Response] {.async.} =
  echo params.repr
  return render("")
