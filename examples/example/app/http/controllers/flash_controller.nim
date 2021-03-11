# framework
import ../../../../../src/basolato/controller
# view
import ../views/pages/sample/flash_view

proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let auth = await newAuth(request)
  return await render(await indexView(auth)).setAuth(auth)

proc store*(request:Request, params:Params):Future[Response] {.async.} =
  let auth = await newAuth(request)
  await auth.setFlash("msg", "This is flash message")
  return redirect("/sample/flash")

proc destroy*(request:Request, params:Params):Future[Response] {.async.} =
  let auth = await newAuth(request)
  await auth.destroy()
  return redirect("/")
