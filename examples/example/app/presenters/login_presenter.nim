import ../../../../src/basolato/view
import ../http/views/pages/sample/login/login_view_model
import ../http/views/pages/sample/login/login_signal


type LoginPresenter* = object

proc new*(_:type LoginPresenter):LoginPresenter =
  return LoginPresenter()


proc invoke*(self:LoginPresenter, isLogin:bool, name:string):LoginViewModel =
  loginUserSignal.set((isLogin:isLogin, name:name))
  return LoginViewModel.new()
