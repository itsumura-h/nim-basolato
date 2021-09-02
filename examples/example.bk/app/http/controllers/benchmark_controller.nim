import asyncdispatch
import ../../../../../src/basolato/controller


proc test1*(request:Request, params:Params):Future[Response] {.async.} =
  await sleepAsync(10000)
  return render("test1")

proc test2*(request:Request, params:Params):Future[Response] {.async.} =
  return render("test2")
