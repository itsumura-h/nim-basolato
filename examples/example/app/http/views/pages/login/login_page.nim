import std/asyncdispatch
import ../../../../../../../src/basolato/view
import ../../templates/login/login_template
import ../../presenters/login/login_page_viewmodel


proc loginPage*():Future[Component] {.async.} =
  let context = context()
  let (params, errors) = context.getParamsWithErrorsList().await
  
  let isLogin = context.isLogin().await
  let name = context.session.get("name").await
  
  let vm = LoginPageViewModel.new(isLogin, name, params, errors)
  return loginTemplate(vm)
