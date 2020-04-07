import json
import ../../app/active_records/rdb

type UserRepository* = ref object

proc newUserRepository*():UserRepository =
  return UserRepository()


proc show*(this:UserRepository, id:int):JsonNode =
  newUser().find(id)