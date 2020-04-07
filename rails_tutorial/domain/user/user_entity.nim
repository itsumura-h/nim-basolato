import json
import users_repository

type UserEntity* = ref object

proc newUserEntity*():UserEntity =
  return UserEntity()
