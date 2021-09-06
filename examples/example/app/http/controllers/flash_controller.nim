import json
# framework
import ../../../../../src/basolato/controller
import ../views/pages/sample/flash_view


proc index*(context:Context, params:Params):Future[Response] {.async.} =
  return render(await flash_view(context))

proc store*(context:Context, params:Params):Future[Response] {.async.} =
  await context.setFlash("msg", "This is flash message")
  return redirect("/sample/flash")
