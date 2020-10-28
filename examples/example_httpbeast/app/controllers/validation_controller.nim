import json
# framework
import ../../../../src/basolato_httpbeast/controller
import ../../../../src/basolato_httpbeast/request_validation

proc index*(request:Request, params:Params):Future[Response] {.async.} =
  return render("index")

proc show*(request:Request, params:Params):Future[Response] {.async.} =
  let id = params.urlParams["id"].getInt
  return render("show")

proc create*(request:Request, params:Params):Future[Response] {.async.} =
  return render("create")

proc store*(request:Request, params:Params):Future[Response] {.async.} =
  var validation = newValidation(params.requestParams)
  validation.strictEmail("email")
  validation.password("password")
  validation.valid()
  return render("store")
  # try:
  #   validation.valid()
  #   return render("store")
  # except:
  #   return render(Http400, validation.errors)

proc edit*(request:Request, params:Params):Future[Response] {.async.} =
  let id = params.urlParams["id"].getInt
  return render("edit")

proc update*(request:Request, params:Params):Future[Response] {.async.} =
  let id = params.urlParams["id"].getInt
  return render("update")

proc destroy*(request:Request, params:Params):Future[Response] {.async.} =
  let id = params.urlParams["id"].getInt
  return render("destroy")
