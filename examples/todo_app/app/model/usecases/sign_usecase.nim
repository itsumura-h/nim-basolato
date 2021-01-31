import json
import ../value_objects
import ../aggregates/user/user_entity
import ../aggregates/user/user_repository_interface
import ../aggregates/user/user_service


type SignUsecase* = ref object
  repository:IUserRepository
  service: UserService

proc newSignUsecase*(repository:IUserRepository):SignUsecase =
  return SignUsecase(
    repository: repository,
    service: newUserService(repository)
  )

proc signUp*(this:SignUsecase, name, email, password:string):JsonNode =
  let name = newUserName(name)
  let email = newUserEmail(email)
  let password = newPassword(password).getHashed()
  let userId = this.repository.storeUser(name, email, password)
  return %*{"id": userId.getInt, "name": name}

proc signIn*(this:SignUsecase, email, password:string):JsonNode =
  let email = newUserEmail(email)
  let user = this.repository.getUser(email)
  let password = newPassword(password)
  let hashedPassword = user.hashedPassword()
  if this.service.isMatchPassword(password, hashedPassword):
    return %*{"id": user.id().getInt, "name": $(user.name())}
  else:
    raise newException(Exception, "password not match")