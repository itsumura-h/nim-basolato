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
  let client = await newClient(request)
  return await render(await signupView(client)).setClient(client)

proc signUp*(request:Request, params:Params):Future[Response] {.async.} =
  params.required("name");params.required("email");params.required("password");
  params.email("email")
  let client = await newClient(request)
  if params.hasErrors:
    await client.storeValidationResult(params)
    return redirect("/signup")

  let name = params.getStr("name")
  let email = params.getStr("email")
  let password = params.getStr("password")
  try:
    let repository = newUserRdbRepository().toInterface()
    let usecase = newSignUsecase(repository)
    let user = usecase.signUp(name, email, password)
    await client.login()
    await client.set("id", $(user["id"].getInt))
    await client.set("name", user["name"].getStr)
    return redirect("/")
  except Exception:
    params.errors.add("core", getCurrentExceptionMsg())
    await client.storeValidationResult(params)
    return render(await signupView(client))


proc deleteAccountPage*(request:Request, params:Params):Future[Response] {.async.} =
  return render("delete account")

proc deleteAccount*(request:Request, params:Params):Future[Response] {.async.} =
  return render("delete account")

proc signInPage*(request:Request, params:Params):Future[Response] {.async.} =
  let client = await newClient(request)
  return await render(await signinView(client)).setClient(client)

proc signIn*(request:Request, params:Params):Future[Response] {.async.} =
  params.required("email")
  params.required("password")
  params.email("email")
  let client = await newClient(request)
  if params.hasErrors:
    await client.storeValidationResult(params)
    return redirect("/signin")

  let email = params.getStr("email")
  let password = params.getStr("password")
  try:
    let repository = newUserRdbRepository().toInterface()
    let usecase = newSignUsecase(repository)
    let user = usecase.signIn(email, password)
    await client.login()
    await client.set("id", $(user["id"].getInt))
    await client.set("name", user["name"].getStr)
    return redirect("/")
  except:
    params.errors.add("core", getCurrentExceptionMsg())
    await client.storeValidationResult(params)
    return render(await signInView(client))


proc signOut*(request:Request, params:Params):Future[Response] {.async.} =
  let client = await newClient(request)
  await client.logout()
  return redirect("/signin")

# ==================== API ====================

proc signInApi*(request:Request, params:Params):Future[Response] {.async.} =
  params.required(["email", "password"])
  params.email("email")
  params.password("password")
  let client = await newClient(request)
  if params.hasErrors:
    return render(Http400, %*params.errors)

  let email = params.getStr("email")
  let password = params.getStr("password")
  try:
    let repository = newUserRdbRepository().toInterface()
    let usecase = newSignUsecase(repository)
    let user = usecase.signIn(email, password)
    await client.login()
    await client.set("id", $(user["id"].getInt))
    await client.set("name", user["name"].getStr)
    return await render(Http200, newJObject()).setClient(client)
  except:
    let params = %*{"email": email}
    return render(Http400, %*{"params":params, "error": getCurrentExceptionMsg()})

proc signOutApi*(request:Request, params:Params):Future[Response] {.async.} =
  echo params.repr
  return render("")
