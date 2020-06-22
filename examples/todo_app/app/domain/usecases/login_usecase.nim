import ../models/value_objects
import ../models/user/user_entity
import ../models/user/user_service

type LoginUsecase* = ref object

proc newLoginUsecase*():LoginUsecase =
  return LoginUsecase()


proc signin*(this:LoginUsecase, name, email, password:string) =
  let name = newUserName(name)
  let email = newEmail(email)
  let password = newPassword(password)
  let user = newDraftUser(name, email, password)