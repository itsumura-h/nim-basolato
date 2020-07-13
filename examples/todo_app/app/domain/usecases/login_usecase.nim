import tables

import ../models/value_objects
import ../models/user/user_entity
import ../models/user/user_service
import ../models/user/user_repository_interface

type LoginUsecase* = ref object

proc newLoginUsecase*():LoginUsecase =
  return LoginUsecase()


proc signin*(this:LoginUsecase, name, email, password:string):int =
  let name = newUserName(name)
  let email = newEmail(email)
  let password = newPassword(password)
  let user = newDraftUser(name, email, password)
  let userService = newUserService()
  if userService.isExists(user):
    raise newException(CatchableError, "This email is already used")
  let userId = userService.save(user)
  return userId

proc login*(this:LoginUsecase, email, password:string):int =
  let email = newEmail(email)
  let password = newPassword(password)
  let userService = newUserService()
  let user = userService.find(email)
  userService.checkPasswordValid(user, password)
  return user.id.get()
