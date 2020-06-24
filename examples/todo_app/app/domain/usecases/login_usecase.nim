import ../models/value_objects
import ../models/user/user_entity
import ../models/user/user_service
import ../models/user/user_repository_interface

type LoginUsecase* = ref object
  user_repository:IUserRepository

proc newLoginUsecase*():LoginUsecase =
  return LoginUsecase(
    user_repository:newIUserRepository()
  )


proc signin*(this:LoginUsecase, name, email, password:string):int =
  let name = newUserName(name)
  let email = newEmail(email)
  let password = newPassword(password)
  let user = newDraftUser(name, email, password)
  let user_service = newUserService(this.user_repository)
  if user_service.isExists(user):
    raise newException(Exception, "This email is already used")
  let newUserId = user_service.save(user)
  return newUserId
