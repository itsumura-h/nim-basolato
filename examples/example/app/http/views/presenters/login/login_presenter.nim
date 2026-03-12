import std/asyncdispatch
import ../../../../../../../src/basolato/view
import ./login_page_viewmodel


type LoginPresenter* = object


proc new*(_: type LoginPresenter): LoginPresenter =
  return LoginPresenter()


proc invoke*(self: LoginPresenter, context: Context): Future[LoginPageViewModel] {.async.} =
  # context から必要な値を抽出してViewModel に変換する
  let (params, errors) = context.getParamsWithErrorsList().await
  let isLogin = context.isLogin().await
  let name = context.session.get("name").await
  let csrfToken = context.getCsrfToken()
  
  return LoginPageViewModel.new(isLogin, name, params, errors, csrfToken)
