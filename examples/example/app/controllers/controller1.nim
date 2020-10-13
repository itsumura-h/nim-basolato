import json
import ../../../../src/basolato/controller


proc construct() =
  discard

proc getString*(request:Request, params:Params):Future[Response] {.async.} =
  construct()
  return render("=== getProc")

proc getJson*(request:Request, params:Params):Future[Response] {.async.} =
  construct()
  let response = %*{"key":"val"}
  let headers = (%*{"key1": "val1", "key2": 2}).toHeaders()
  return render(response, headers)

proc dd*(request:Request, params:Params):Future[Response] {.async.} =
  construct()
  let present = %*{"key1": "val1", "key2": "val2"}
  dd($present)
  return render("===")

proc redirect*(request:Request, params:Params):Future[Response] {.async.} =
  construct()
  return redirect("https://google.com")

proc postString*(request:Request, params:Params):Future[Response] {.async.} =
  construct()
  if params.requestParams.hasKey("img"):
    params.requestParams["img"].save("/var/tmp")
    params.requestParams["img"].save("/var/tmp", "iamge")

  if params.requestParams.hasKey("txt"):
    params.requestParams["txt"].save("/var/tmp")
    params.requestParams["txt"].save("/var/tmp", "text")

  let response = %*{
    "filename": params.requestParams["txt"].filename,
    "value": params.requestParams.get("txt")
  }
  return render(response)
