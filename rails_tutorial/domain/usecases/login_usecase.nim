import json
import ../models/value_objects
import ../models/user/user_entity
import ../models/user/user_repository_interface
import ../models/user/user_service

type LoginUsecase* = ref object
  service:UserService
  repository:UserRepository

proc newLoginUsecase*():LoginUsecase =
  return LoginUsecase(
    service:newUserService(),
    repository:newIUserRepository(),
  )


proc login*(this:LoginUsecase, email="", inputPassword=""):int =
  let email = newEmail(email)
  let inputPassword = newPassword(inputPassword)
  let draftUser = newUser(email=email, password=inputPassword)
  let userData = this.repository.getUserDataByEmail(email)
  let dbPassword = userData["password"].getStr()
  if dbPassword.len == 0:
    raise newException(Exception, "Invalid email or password")
  if not this.service.isMatchPassword(draftUser, dbPassword):
    raise newException(Exception, "Invalid email or password")
  return userData["id"].getInt()
