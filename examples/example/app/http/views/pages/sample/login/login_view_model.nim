import ../../../../../../../../src/basolato/view
import ./login_signal

type LoginViewModel* = object
  isLogin*:bool
  name*:string


proc new*(_:type LoginViewModel):LoginViewModel =
  let (isLogin, name) = loginUserSignal.get()
  return LoginViewModel(isLogin:isLogin, name:name)
