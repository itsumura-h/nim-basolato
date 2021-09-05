import json, strutils
# framework
import ../../../../../../src/basolato/controller
import ../../../../../../src/basolato/request_validation
# usecase
import ../../../usecases/sign/signin_usecase
# view
import ../../views/pages/sign/signin_view

proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let client = await newClient(request)
  let (params, errors) = await client.getValidationResult()
  return render(signinView(params, errors))

proc store*(request:Request, params:Params):Future[Response] {.async.} =
  let email = params.getStr("email")
  let password = params.getStr("password")
  let v = newRequestValidation(params)
  v.required("email")
  v.required("password")
  v.email("email")
  let client = await newClient(request)
  if v.hasErrors():
    await client.storeValidationResult(v)
    return redirect("/signin")

  try:
    let usecase = SigninUsecase.new()
    let user = await usecase.run(email, password)
    await client.login()
    await client.set("id", $user["id"].getInt)
    await client.set("name", user["name"].getStr)
    return redirect("/todo")
  except:
    v.errors.add("error", getCurrentExceptionMsg().splitLines()[0])
    await client.storeValidationResult(v)
    return redirect("/signin")

proc delete*(request:Request, params:Params):Future[Response] {.async.} =
  let client = await newClient(request)
  await client.logout()
  return redirect("/signin")
