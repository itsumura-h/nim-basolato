import std/asyncdispatch
import std/json
# framework
import basolato/controller
import basolato/log


proc index*(context:Context, params:Params):Future[Response] {.async.} =
  echoLog("=== index")
  echoErrorMsg("=== index, errpr")
  echo "aaa"
  return render("")

proc show*(context:Context, params:Params):Future[Response] {.async.} =
  let id = params.getStr("id")
  return render(id)

proc store*(context:Context, params:Params):Future[Response] {.async.} =
  return render("")
