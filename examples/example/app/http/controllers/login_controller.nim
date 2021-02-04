# framework
import ../../../../../src/basolato/controller
# view
import ../views/pages/sample/login_view


proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let auth = await newAuth(request)
  return render(await loginView(auth))

proc store*(request:Request, params:Params):Future[Response] {.async.} =
  let name = params.getStr("name")
  let password = params.getStr("password")
  # auth
  let auth = await newAuth(request)
  await auth.login()
  await auth.set("name", name)
  return await redirect("/sample/login").setAuth(auth)

proc destroy*(request:Request, params:Params):Future[Response] {.async.} =
  let auth = await newAuth(request)
  await auth.destroy()
  return await redirect("/sample/login").setAuth(auth)
