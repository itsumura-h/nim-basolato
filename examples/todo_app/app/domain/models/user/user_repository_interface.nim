import json, options
import ../value_objects
import user_entity
include ../di_container

type IUserRepository* = ref object

proc newIUserRepository*():IUserRepository =
  return IUserRepository()

proc find*(this:IUserRepository, email:Email):Option[User] =
  return DiContainer.userRepository().find(email)

proc save*(this:IUserRepository, user:User):int =
  return DiContainer.userRepository().save(user)