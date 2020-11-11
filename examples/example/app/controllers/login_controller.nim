# framework
import ../../../../src/basolato/controller
# view
import ../../resources/pages/sample/login_view


proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let auth = newAuth(request)
  return render(loginView(auth))

proc store*(request:Request, params:Params):Future[Response] {.async.} =
  let name = params.requestParams.get("name")
  # let password = params.requestParams.get("password")
  # auth
  let auth = newAuth()
  auth.login()
  auth.set("name", name)
  return redirect("/sample/login").setAuth(auth)

proc destroy*(request:Request, params:Params):Future[Response] {.async.} =
  let auth = newAuth(request)
  return redirect("/sample/login").destroyAuth(auth)
