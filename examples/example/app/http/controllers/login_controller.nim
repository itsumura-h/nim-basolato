import json
# framework
import ../../../../../src/basolato/controller
#view
import ../views/pages/sample/login_view


proc index*(context:Context, params:Params):Future[Response] {.async.} =
  return render(await loginView(context))

proc store*(context:Context, params:Params):Future[Response] {.async.} =
  let name = params.getStr("name")
  let password = params.getStr("password")
  # client
  await context.login()
  await context.set("name", name)
  return redirect("/sample/login")

proc destroy*(context:Context, params:Params):Future[Response] {.async.} =
  await context.destroy()
  return await redirect("/sample/login").destroyContext(context)