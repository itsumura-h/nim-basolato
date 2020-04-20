import json
import bcrypt
import ../value_objects
import user_entity
import user_repository_interface

type UserService* = ref object
  repository:UserRepository

proc newUserService*():UserService =
  return UserService(
    repository:newIUserRepository()
  )


proc isMatchPassword*(this:UserService, user:User, dbPassword:string):bool =
  let inputPassword = user.getHashedPassword()
  return compare(inputPassword, dbPassword)
