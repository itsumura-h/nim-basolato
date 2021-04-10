import json
import ../models/user/value_objects
import ../models/user/user_entity
import ../models/user/user_repository_interface
import ../models/user/user_service


type SignUsecase* = ref object
  repository:IUserRepository
  service: UserService

proc newSignUsecase*(repository:IUserRepository):SignUsecase =
  return SignUsecase(
    repository: repository,
    service: newUserService(repository)
  )

proc signUp*(self:SignUsecase, name, email, password:string):JsonNode =
  let name = newUserName(name)
  let email = newUserEmail(email)
  let password = newPassword(password).getHashed()
  let userId = self.repository.storeUser(name, email, password)
  return %*{"id": userId.getInt, "name": name}

proc signIn*(self:SignUsecase, email, password:string):JsonNode =
  let email = newUserEmail(email)
  let user = self.repository.getUser(email)
  let password = newPassword(password)
  let hashedPassword = user.hashedPassword()
  if self.service.isMatchPassword(password, hashedPassword):
    return %*{"id": user.id().getInt, "name": $(user.name())}
  else:
    raise newException(Exception, "password not match")
