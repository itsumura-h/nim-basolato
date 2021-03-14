import json
# framework
import ../../../../../src/basolato/controller
import ../../../../../src/basolato/request_validation
# view
import ../views/pages/sample/validation_view

proc index*(request:Request, params:Params):Future[Response] {.async.} =
  return render(validationView())

proc show*(request:Request, params:Params):Future[Response] {.async.} =
  let id = params.getInt("id")
  return render("show")

proc create*(request:Request, params:Params):Future[Response] {.async.} =
  return render("create")

proc store*(request:Request, params:Params):Future[Response] {.async.} =
  var validation = newValidation(params)
  dd(params.repr)
  validation.strictEmail("email")
  validation.password("password")
  validation.valid()
  try:
    validation.valid()
    return redirect("/sample/validation")
  except:
    return render(Http400, validation.errors)

proc edit*(request:Request, params:Params):Future[Response] {.async.} =
  let id = params.getInt("id")
  return render("edit")

proc update*(request:Request, params:Params):Future[Response] {.async.} =
  let id = params.getInt("id")
  return render("update")

proc destroy*(request:Request, params:Params):Future[Response] {.async.} =
  let id = params.getInt("id")
  return render("destroy")
