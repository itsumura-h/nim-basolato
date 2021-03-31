# framework
import ../../../../../src/basolato/controller
# view
import ../views/pages/sample/login_view


proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let client = await newClient(request)
  return render(await loginView(client))

proc store*(request:Request, params:Params):Future[Response] {.async.} =
  let name = params.getStr("name")
  let password = params.getStr("password")
  # client
  let client = await newClient(request)
  await client.login()
  await client.set("name", name)
  return await redirect("/sample/login").setClient(client)

proc destroy*(request:Request, params:Params):Future[Response] {.async.} =
  let client = await newClient(request)
  await client.destroy()
  return await redirect("/sample/login").setClient(client)
