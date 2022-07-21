import json
# framework
import ../../../../../src/basolato2/controller


proc get*(context:Context, params:Params):Future[Response] {.async.} =
  return render("get")

proc post*(context:Context, params:Params):Future[Response] {.async.} =
  let id = params.getInt("id")
  return render("post")

proc put*(context:Context, params:Params):Future[Response] {.async.} =
  return render("put")

proc patch*(context:Context, params:Params):Future[Response] {.async.} =
  return render("patch")

proc delete*(context:Context, params:Params):Future[Response] {.async.} =
  let id = params.getInt("id")
  return render("delete")
