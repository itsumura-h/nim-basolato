# framework
import ../../../..//src/basolato_httpbeast/controller
# view
import ../../resources/pages/sample/flash

proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let auth = newAuth(request)
  return render(indexView(auth))

proc store*(request:Request, params:Params):Future[Response] {.async.} =
  let auth = newAuth(request)
  if not auth.isLogin:
    auth.login()
  auth.setFlash("msg", "This is flash message")
  return redirect("/sample/flash").setAuth(auth)

proc destroy*(request:Request, params:Params):Future[Response] {.async.} =
  let auth = newAuth(request)
  return redirect("/").destroyAuth(auth)
