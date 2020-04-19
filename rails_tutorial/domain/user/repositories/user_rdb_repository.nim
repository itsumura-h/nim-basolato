import json
import ../../../app/active_records/rdb
import ../user_entity

type UserRepository* = ref object

proc newUserRepository*():UserRepository =
  return UserRepository()


proc show*(this:UserRepository, user:User):JsonNode =
  return newUser().find(user.getId)

proc store*(this:UserRepository, user:User):int =
  newUser().insertID(%*{
    "name": user.getName(),
    "email": user.getEmail(),
    "password": user.getHashedPassword()
  })

proc getPasswordByEmail*(this:UserRepository, user:User):string =
  return newUser()
    .select("password")
    .where("email", "=", user.getEmail())
    .first()["password"]
    .getStr()
