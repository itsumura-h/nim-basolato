import json
import ../models/value_objects
import ../models/user/user_entity
import ../models/user/user_repository_interface
import ../models/user/user_service


type SignUsecase* = ref object
  repository:IUserRepository
  service: UserService

proc newSignUsecase*():SignUsecase =
  return SignUsecase(
    repository: IUserRepository()
  )

proc signUp*(this:SignUsecase, name, email, password:string):JsonNode =
  let name = newUserName(name)
  let email = newUserEmail(email)
  let password = newPassword(password).getHashed()
  let userId = this.repository.storeUser(name, email, password)
  return %*{"id": userId.get, "name": name}

proc signIn*(this:SignUsecase, email, password:string):JsonNode =
  let email = newUserEmail(email)
  let user = this.repository.getUser(email)
  let password = newPassword(password)
  let hashedPassword = user.hashedPassword()
  if this.service.isMatchPassword(password, hashedPassword):
    return %*{"id": user.id().get, "name": user.name().get}
  else:
    raise newException(Exception, "password not match")
