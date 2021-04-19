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
  return render(await signupView(client))

proc signUp*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  v.required("name")
  v.required("email"); v.email("email")
  v.required("password"); v.minStr("password", 8);
  v.required("password_confirmation", attribute="password confirmation"); v.confirmed("password");
  let client = await newClient(request)
  if v.hasErrors:
    await client.storeValidationResult(v)
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
    v.errors.add("core", getCurrentExceptionMsg())
    await client.storeValidationResult(v)
    return render(await signupView(client))


proc deleteAccountPage*(request:Request, params:Params):Future[Response] {.async.} =
  return render("delete account")

proc deleteAccount*(request:Request, params:Params):Future[Response] {.async.} =
  return render("delete account")

proc signInPage*(request:Request, params:Params):Future[Response] {.async.} =
  let client = await newClient(request)
  return await render(await signinView(client)).setCookie(client)

proc signIn*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  v.required("email")
  v.required("password")
  v.email("email")
  let client = await newClient(request)
  if v.hasErrors:
    await client.storeValidationResult(v)
    return redirect(request.path)

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
    v.errors.add("core", getCurrentExceptionMsg())
    await client.storeValidationResult(v)
    return render(await signInView(client))


proc signOut*(request:Request, params:Params):Future[Response] {.async.} =
  let client = await newClient(request)
  await client.logout()
  return redirect("/signin")

# ==================== API ====================

proc signInApi*(request:Request, params:Params):Future[Response] {.async.} =
  let v = newRequestValidation(params)
  v.required(["email", "password"])
  v.email("email")
  let client = await newClient(request)
  if v.hasErrors:
    return render(Http400, %v.errors)

  let email = params.getStr("email")
  let password = params.getStr("password")
  try:
    let repository = newUserRdbRepository().toInterface()
    let usecase = newSignUsecase(repository)
    let user = usecase.signIn(email, password)
    await client.login()
    await client.set("id", $(user["id"].getInt))
    await client.set("name", user["name"].getStr)
    return await render(Http200, newJObject()).setCookie(client)
  except:
    v.errors.add("core", getCurrentExceptionMsg())
    return await render(Http400, %*{"params": params, "errors": v.errors}).setCookie(client)

proc signOutApi*(request:Request, params:Params):Future[Response] {.async.} =
  echo params.repr
  return render("")
