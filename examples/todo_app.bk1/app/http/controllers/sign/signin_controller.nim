import json, strutils
# framework
import ../../../../../../src/basolato/controller
import ../../../../../../src/basolato/request_validation
# usecase
import ../../../usecases/sign/signin_usecase
# view
import ../../views/pages/sign/signin_view

proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let (params, errors) = await context.getValidationResult()
  return render(signinView(params, errors))

proc store*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  v.required("email")
  v.required("password")
  v.email("email")
  if v.hasErrors():
    await context.storeValidationResult(v)
    return redirect("/signin")

  let email = params.getStr("email")
  let password = params.getStr("password")
  try:
    let usecase = SigninUsecase.new()
    let user = await usecase.run(email, password)
    await context.login()
    await context.set("id", user["id"].getStr)
    await context.set("name", user["name"].getStr)
    await context.set("auth", $user["auth"].getInt)
    return redirect("/todo")
  except:
    v.errors.add("error", getCurrentExceptionMsg().splitLines()[0])
    await context.storeValidationResult(v)
    return redirect("/signin")

proc delete*(context:Context, params:Params):Future[Response] {.async.} =
  await context.logout()
  return redirect("/signin")
