type SignInViewModel*  = object
  oldEmail*:string

proc new*(_:type SignInViewModel, oldEmail:string): SignInViewModel =
  return SignInViewModel(oldEmail:oldEmail)
