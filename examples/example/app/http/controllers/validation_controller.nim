import json
# framework
import ../../../../../src/basolato/controller
import ../../../../../src/basolato/request_validation
# view
import ../views/pages/sample/validation_view

proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let (params, errors) = await context.getValidationResult()
  echo params, errors
  return render(await validationView(params, errors))

proc store*(context:Context, params:Params):Future[Response] {.async.} =
  let validation = RequestValidation.new(params)
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
    await context.storeValidationResult(validation)
  return redirect("/sample/validation")
