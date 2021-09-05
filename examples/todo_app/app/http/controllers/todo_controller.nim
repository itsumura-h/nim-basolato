import json
# framework
import ../../../../../src/basolato/controller
# view
import ../views/pages/todo/index_view

proc index*(request:Request, params:Params):Future[Response] {.async.} =
  return render(indexView())

proc show*(request:Request, params:Params):Future[Response] {.async.} =
  let id = params.getInt("id")
  return render("show")

proc create*(request:Request, params:Params):Future[Response] {.async.} =
  return render("create")

proc store*(request:Request, params:Params):Future[Response] {.async.} =
  return render("store")

proc edit*(request:Request, params:Params):Future[Response] {.async.} =
  let id = params.getInt("id")
  return render("edit")

proc update*(request:Request, params:Params):Future[Response] {.async.} =
  let id = params.getInt("id")
  return render("update")

proc destroy*(request:Request, params:Params):Future[Response] {.async.} =
  let id = params.getInt("id")
  return render("destroy")
