import std/asyncdispatch
import ../../../../../../../src/basolato/view
import ../../signals/login_signal
import ../../signals/form_signal
import ../../templates/login/login_template


proc loginPage*():Future[Component] {.async.} =
  let context = context()
  let (params, errors) = context.getParamsWithErrorsList().await
  formParamsSignal.value = params
  formErrorsSignal.value = errors
  
  let isLogin = context.isLogin().await
  let name = context.get("name").await
  loginUserSignal.value = (isLogin: isLogin, name: name)
  return loginTemplate()
