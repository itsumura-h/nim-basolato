import std/asyncdispatch
import std/json
# framework
import ../../../../../src/basolato/controller


proc get*(context:Context):Future[Response] {.async.} =
  return render("get")

proc post*(context:Context):Future[Response] {.async.} =
  let id = context.params.getInt("id")
  return render("post")

proc put*(context:Context):Future[Response] {.async.} =
  return render("put")

proc patch*(context:Context):Future[Response] {.async.} =
  return render("patch")

proc delete*(context:Context):Future[Response] {.async.} =
  let id = context.params.getInt("id")
  return render("delete")
