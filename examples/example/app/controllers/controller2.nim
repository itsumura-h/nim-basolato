import ../../../../src/basolato/controller


proc construct() =
  discard

proc getString*(request:Request, params:Params):Future[Response] {.async.} =
  construct()
  # echo params.urlParams
  # echo params.queryParams
  return render("=== getProc2")
