import tables

import ../models/value_objects
import ../models/user/user_entity
import ../models/user/user_service
import ../models/user/repositories/user_repository
import ../models/di_container

type LoginUsecase* = ref object
  userRepository:UserRepository

proc newLoginUsecase*():LoginUsecase =
  return LoginUsecase(
    userRepository:dependencies["userRepository"]
  )


proc signin*(this:LoginUsecase, name, email, password:string):int =
  let name = newUserName(name)
  let email = newEmail(email)
  let password = newPassword(password)
  let user = newDraftUser(name, email, password)
  let userService = newUserService(this.user_repository)
  if userService.isExists(user):
    raise newException(CatchableError, "This email is already used")
  let userId = userService.save(user)
  return userId

proc login*(this:LoginUsecase, email, password:string):int =
  let email = newEmail(email)
  let password = newPassword(password)
  let userService = newUserService(this.userRepository)
  let user = userService.find(email)
  userService.checkPasswordValid(user, password)
  return user.id.get()
