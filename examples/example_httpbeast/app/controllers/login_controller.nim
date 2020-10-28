# framework
import ../../../../src/basolato_httpbeast/controller
# view
import ../../resources/pages/sample/login


proc indexLogin*(request:Request, params:Params):Future[Response] {.async.} =
  let auth = newAuth(request)
  return render(loginView(auth))

proc storeLogin*(request:Request, params:Params):Future[Response] {.async.} =
  let name = params.requestParams.get("name")
  let password = params.requestParams.get("password")
  # auth
  let auth = newAuth()
  auth.login()
  auth.set("name", name)
  return redirect("/sample/login").setAuth(auth)

proc destroyLogin*(request:Request, params:Params):Future[Response] {.async.} =
  let auth = newAuth(request)
  return redirect("/sample/login").destroyAuth(auth)
