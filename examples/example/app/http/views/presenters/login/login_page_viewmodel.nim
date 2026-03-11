import ../../../../../../../src/basolato/view


type LoginPageViewModel* = object
  isLogin*: bool
  name*: string
  formParams*: Params
  formErrors*: seq[string]


proc new*(_: type LoginPageViewModel, isLogin: bool, name: string, formParams: Params, formErrors: seq[string]): LoginPageViewModel =
  return LoginPageViewModel(
    isLogin: isLogin,
    name: name,
    formParams: formParams,
    formErrors: formErrors
  )
