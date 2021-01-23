import ../value_objects
include ../di_container
import ./user_entity

type IUserRepository* = ref object


proc newIUserRepository*():IUserRepository =
  return newIUserRepository()

proc storeUser*(this:IUserRepository,
  name:UserName,
  email:UserEmail,
  hashedPassword:HashedPassword
):UserId =
  return DiContainer.userRepository().storeUser(name, email, hashedPassword)

proc getUser*(this:IUserRepository, email:UserEmail):User =
  return DiContainer.userRepository().getUser(email)
