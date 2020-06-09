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

proc login*(this:LoginUsecase, email="", inputPassword=""):JsonNode =
  let email = newEmail(email)
  let inputPassword = newPassword(inputPassword)
  let draftUser = newUser(email=email, password=inputPassword)
  let userData = this.repository.getUserDataByEmail(email)
  # user not found
  if userData.kind == JNull:
    raise newException(Exception, "Invalid email or password")
  let dbPassword = userData["password"].getStr()
  # password not match
  if not this.service.isMatchPassword(draftUser, dbPassword):
    raise newException(Exception, "Invalid email or password")
  return %*{
    "id":userData["id"].getInt(),
    "name":userData["name"].getStr()
  }
