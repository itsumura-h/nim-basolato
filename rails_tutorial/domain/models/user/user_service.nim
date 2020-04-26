import bcrypt
import user_entity
import user_repository_interface

type UserService* = ref object
  repository:UserRepository

proc newUserService*():UserService =
  return UserService(
    repository:newIUserRepository()
  )


proc isMatchPassword*(this:UserService, draftUser:User, dbPassword:string):bool =
  let inputPassword = draftUser.getHashedPassword()
  return compare(inputPassword, dbPassword)
