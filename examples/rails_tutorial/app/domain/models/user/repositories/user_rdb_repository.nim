import json
import ../../../../active_records/rdb
import ../user_entity
import ../../value_objects

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

proc getUserDataByEmail*(this:UserRepository, email:Email):JsonNode =
  return newUser()
    .where("email", "=", email.get())
    .first()
