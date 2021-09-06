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
  let email = params.getStr("email")
  let password = params.getStr("password")
  let v = newRequestValidation(params)
  v.required("email")
  v.required("password")
  v.email("email")
  if v.hasErrors():
    await context.storeValidationResult(v)
    return redirect("/signin")

  try:
    let usecase = SigninUsecase.new()
    let user = await usecase.run(email, password)
    await context.login()
    await context.session.set("id", $user["id"].getInt)
    await context.session.set("name", user["name"].getStr)
    return redirect("/todo")
  except:
    v.errors.add("error", getCurrentExceptionMsg().splitLines()[0])
    await context.storeValidationResult(v)
    return redirect("/signin")

proc delete*(context:Context, params:Params):Future[Response] {.async.} =
  await context.logout()
  return redirect("/signin")
