import json
import users_repository

type UserService* = ref object

proc newUserService():UserService =
  return UserService()


proc show*(this:UserService, id:int):JsonNode =
  return newUserRepository().show(id)
