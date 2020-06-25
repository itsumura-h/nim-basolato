import ../models/value_objects
import ../models/user/user_entity
import ../models/user/user_service
import ../models/user/user_repository_interface

type LoginUsecase* = ref object
  userRepository:IUserRepository

proc newLoginUsecase*():LoginUsecase =
  return LoginUsecase(
    userRepository:newIUserRepository()
  )


proc signin*(this:LoginUsecase, name, email, password:string):int =
  let name = newUserName(name)
  let email = newEmail(email)
  let password = newPassword(password)
  let user = newDraftUser(name, email, password)
  let userService = newUserService(this.user_repository)
  if userService.isExists(user):
    raise newException(Exception, "This email is already used")
  let newUserId = userService.save(user)
  return newUserId
