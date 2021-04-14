import json
# framework
import ../../../../../src/basolato/controller
import ../../../../../src/basolato/request_validation
# view
import ../views/pages/sample/validation_view

proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let client = await newClient(request)
  return await render(await validationView(client)).setCookie(client)

proc show*(request:Request, params:Params):Future[Response] {.async.} =
  let id = params.getInt("id")
  return render("show")

proc create*(request:Request, params:Params):Future[Response] {.async.} =
  return render("create")

proc store*(request:Request, params:Params):Future[Response] {.async.} =
  let validation = newRequestValidation(params)
  # email
  validation.required("email", attribute="mail address")
  validation.email("email", attribute="mail address")
  # password
  validation.required("password")
  validation.required("password_confirmation", attribute="password confirmation")
  validation.confirmed("password")
  # number, float
  validation.required("number")
  validation.required("float")
  validation.betweenNum("number", 1, 10)
  validation.betweenNum("float", 0.1, 1.0)
  if validation.hasErrors:
    let client = await newClient(request)
    await client.storeValidationResult(validation)
  return redirect("/sample/validation")

proc edit*(request:Request, params:Params):Future[Response] {.async.} =
  let id = params.getInt("id")
  return render("edit")

proc update*(request:Request, params:Params):Future[Response] {.async.} =
  let id = params.getInt("id")
  return render("update")

proc destroy*(request:Request, params:Params):Future[Response] {.async.} =
  let id = params.getInt("id")
  return render("destroy")
