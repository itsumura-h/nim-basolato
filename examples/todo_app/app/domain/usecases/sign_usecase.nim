import ../models/value_objects


type SignUsecase* = ref object

proc newSignUsecase*():SignUsecase =
  return SignUsecase()

proc signIn*(this:SignUsecase, name, email, password:string) =
  let name = newUserName(name)
  let email = newUserEmail(email)
  let password = newPassword(password)
  echo name.repr, email.repr, password.repr
