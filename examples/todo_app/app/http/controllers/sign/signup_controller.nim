import json, strutils
# framework
import ../../../../../../src/basolato/controller
import ../../../../../../src/basolato/request_validation
import ../../../usecases/sign/signup_usecase
import ../../views/pages/sign/signup_view


proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let (params, errors) = await context.getValidationResult()
  return render(signupView(params, errors).await)

proc store*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  v.required("name")
  v.required("email")
  v.email("email")
  v.required("password")
  v.same("password_confirm", "password", "password confirm")
  if v.hasErrors:
    await context.storeValidationResult(v)
    return redirect("/signup")

  let name = params.getStr("name")
  let email = params.getStr("email")
  let password = params.getStr("password")
  try:
    let usecase = SignupUsecase.new()
    let id = await usecase.run(name, email, password)
    await context.login()
    await context.set("id", $id)
    await context.set("name", name)
    return redirect("/todo")
  except:
    v.errors.add("error", getCurrentExceptionMsg().splitLines()[0])
    await context.storeValidationResult(v)
    return redirect("/signup")
