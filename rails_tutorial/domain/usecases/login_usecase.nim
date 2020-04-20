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
  let user = newUser(email=email, password=inputPassword)
  let userData = this.repository.getUserDataByEmail(email)
  let dbPassword = userData["password"].getStr()
  if dbPassword.len == 0:
    raise newException(Exception, "Invalid email")
  if not this.service.isMatchPassword(user, dbPassword):
    raise newException(Exception, "password is not match")