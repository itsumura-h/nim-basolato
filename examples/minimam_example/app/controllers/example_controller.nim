import ../../../../src/basolato/controller


proc index*(context:Context, params:Params):Future[Response] {.async.} =
  return render("index")

proc show*(context:Context, params:Params):Future[Response] {.async.} =
  return render("show")
