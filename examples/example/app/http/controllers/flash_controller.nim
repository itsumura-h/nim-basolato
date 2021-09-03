import json
# framework
import ../../../../../src/basolato/controller
import ../views/pages/sample/flash_view


proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let client = await newClient(request)
  return await render(await flash_view(client)).setCookie(client)

proc store*(request:Request, params:Params):Future[Response] {.async.} =
  let client = await newClient(request)
  await client.setFlash("msg", "This is flash message")
  return redirect("/sample/flash")
