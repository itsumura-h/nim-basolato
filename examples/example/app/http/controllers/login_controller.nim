import std/asyncdispatch
import std/json
# framework
import ../../../../../src/basolato/controller
#view
import ../../presenters/login_presenter
import ../views/pages/sample/login/login_view_model
import ../views/pages/sample/login/login_view


proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let isLogin = context.isLogin().await
  let name = context.get("name").await
  let loginPresenter = LoginPresenter.new()
  let loginViewModel = loginPresenter.invoke(isLogin, name)
  return render(loginView(loginViewModel))

proc store*(context:Context, params:Params):Future[Response] {.async.} =
  let name = params.getStr("name")
  let password = params.getStr("password")
  # client
  await context.set("name", name)
  await context.login()
  return redirect("/sample/login")

proc destroy*(context:Context, params:Params):Future[Response] {.async.} =
  await context.logout()
  await context.delete("name")
  return redirect("/sample/login")
