import json
# framework
import ../../../../../../src/basolato/controller
# view
import ../../views/pages/sign/signup_view

proc index*(context:Context, params:Params):Future[Response] {.async.} =
  return render(signupView())

proc show*(context:Context, params:Params):Future[Response] {.async.} =
  let id = params.getInt("id")
  return render("show")

proc create*(context:Context, params:Params):Future[Response] {.async.} =
  return render("create")

proc store*(context:Context, params:Params):Future[Response] {.async.} =
  return render("store")

proc edit*(context:Context, params:Params):Future[Response] {.async.} =
  let id = params.getInt("id")
  return render("edit")

proc update*(context:Context, params:Params):Future[Response] {.async.} =
  let id = params.getInt("id")
  return render("update")

proc destroy*(context:Context, params:Params):Future[Response] {.async.} =
  let id = params.getInt("id")
  return render("destroy")
