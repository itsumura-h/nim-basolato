import ../value_objects
import user_entity
import user_repository_interface


type UserService* = ref object
  repository:IUserRepository


proc newUserService*():UserService =
  return UserService(
    repository:newIUserRepository()
  )
