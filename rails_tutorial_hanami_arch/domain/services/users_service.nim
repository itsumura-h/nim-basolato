import json
import ../entities/users_entity
import ../repositories/rdb/users_repository

type UserService = ref object

proc newUserService*():UserService =
  return UserService()


proc show*(this:UserService, id:int): JsonNode =
  return newUserRepository().show(id)
