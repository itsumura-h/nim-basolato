import json
import ..//models/value_objects
import ../models/user/user_entity
import ../models/user/user_repository_interface
import ../models/user/user_service

type UsersUsecase* = ref object
  repository:UserRepository

proc newUsersUsecase*():UsersUsecase =
  return UsersUsecase(repository:newIUserRepository())


proc show*(this:UsersUsecase, id:int):JsonNode =
  let id = newId(id)
  let user = newUser(id)
  return this.repository.show(user)

proc store*(this:UsersUsecase, name="", email="", password=""):int =
  let name = newUserName(name)
  let email = newEmail(email)
  let password = newPassword(password)
  let user = newUser(name=name, email=email, password=password)
  let id = this.repository.store(user)
  let userId = newId(id).get()
  return userId
