import ../../http/views/pages/signup/signup_view_model

type SignUpPresenter* = object

proc new*(_:type SignUpPresenter):SignUpPresenter =
  return SignUpPresenter()


proc invoke*(self:SignUpPresenter, oldName:string, oldEmail:string):SignUpViewModel =
  return SignUpViewModel(
    oldName:oldName,
    oldEmail:oldEmail,
  )
