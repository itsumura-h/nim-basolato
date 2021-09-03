import json, asyncdispatch
import ../models/user/user_value_objects
import ../models/user/user_entity
import ../models/user/user_repository_interface
import ../models/user/user_service
import ../di_container


type SignUsecase* = ref object
  repository:IUserRepository
  service: UserService

proc newSignUsecase*():SignUsecase =
  return SignUsecase(
    repository: di.userRepository,
    service: newUserService(di.userRepository)
  )

proc signUp*(self:SignUsecase, name, email, password:string):Future[JsonNode] {.async.} =
  let name = newUserName(name)
  let email = newUserEmail(email)
  let password = newPassword(password).getHashed()
  let userId = await self.repository.storeUser(name, email, password)
  return %*{"id": userId.getInt, "name": name}

proc signIn*(self:SignUsecase, email, password:string):Future[JsonNode] {.async.} =
  let email = newUserEmail(email)
  let user = await self.repository.getUser(email)
  let password = newPassword(password)
  let hashedPassword = user.hashedPassword()
  if self.service.isMatchPassword(password, hashedPassword):
    return %*{"id": user.id().getInt, "name": $(user.name())}
  else:
    raise newException(Exception, "password not match")
