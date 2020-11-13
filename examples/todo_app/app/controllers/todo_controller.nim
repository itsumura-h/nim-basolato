import json
# framework
import ../../../../src/basolato/controller

proc index*(request:Request, params:Params):Future[Response] {.async.} =
  return render("index")

proc show*(request:Request, params:Params):Future[Response] {.async.} =
  let id = params.urlParams["id"].getInt
  return render("show")

proc create*(request:Request, params:Params):Future[Response] {.async.} =
  return render("create")

proc store*(request:Request, params:Params):Future[Response] {.async.} =
  return render("store")

proc edit*(request:Request, params:Params):Future[Response] {.async.} =
  let id = params.urlParams["id"].getInt
  return render("edit")

proc update*(request:Request, params:Params):Future[Response] {.async.} =
  let id = params.urlParams["id"].getInt
  return render("update")

proc destroy*(request:Request, params:Params):Future[Response] {.async.} =
  let id = params.urlParams["id"].getInt
  return render("destroy")
