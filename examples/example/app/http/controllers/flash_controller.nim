# framework
import ../../../../../src/basolato/controller
# view
import ../views/pages/sample/flash_view

proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let client = await newClient(request)
  return await render(await indexView(client)).setClient(client)

proc store*(request:Request, params:Params):Future[Response] {.async.} =
  let client = await newClient(request)
  await client.setFlash("msg", "This is flash message")
  return redirect("/sample/flash")

proc destroy*(request:Request, params:Params):Future[Response] {.async.} =
  let client = await newClient(request)
  await client.destroy()
  return redirect("/")
