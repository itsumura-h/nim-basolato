# framework
import ../../../..//src/basolato/controller
# view
import ../../resources/pages/sample/flash_view

proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let auth = await newAuth(request)
  return render(await indexView(auth))

proc store*(request:Request, params:Params):Future[Response] {.async.} =
  let auth = await newAuth(request)
  if not await auth.isLogin:
    await auth.login()
  await auth.setFlash("msg", "This is flash message")
  return redirect("/sample/flash")

proc destroy*(request:Request, params:Params):Future[Response] {.async.} =
  let auth = await newAuth(request)
  await auth.destroy()
  return redirect("/")
