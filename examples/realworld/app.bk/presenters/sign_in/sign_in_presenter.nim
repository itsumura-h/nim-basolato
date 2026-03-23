import ../../http/views/pages/signin/signin_view_model

type SignInPresenter* = object

proc new*(_:type SignInPresenter):SignInPresenter =
  return SignInPresenter()

proc invoke*(self:SignInPresenter, oldEmail:string):SignInViewModel =
  return SignInViewModel.new(oldEmail)
