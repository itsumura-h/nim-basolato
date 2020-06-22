import user_entity
import user_repository_interface

type UserService* = ref object
  repository:UserRepository

proc newUserService*():UserService =
  return UserService(
    repository:newIUserRepository()
  )

proc isExists(this:UserService, user:User):bool =
  var duplicateUser = this.repository.find(user.name.get())