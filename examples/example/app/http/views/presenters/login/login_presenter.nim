import ../../../../../../../src/basolato/view
import ./login_page_viewmodel


type LoginPresenter* = object


proc new*(_: type LoginPresenter): LoginPresenter =
  return LoginPresenter()


proc invoke*(self: LoginPresenter, isLogin: bool, name: string, formParams: Params, formErrors: seq[string]): LoginPageViewModel =
  return LoginPageViewModel.new(isLogin, name, formParams, formErrors)
