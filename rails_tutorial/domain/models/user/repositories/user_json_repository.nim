import json
import ../user_entity

type UserRepository* = ref object

proc newUserRepository*():UserRepository =
  return UserRepository()


proc show*(this:UserRepository, user:User):JsonNode =
  let jsonObj = parseFile("user.json")
  result = newJNull()
  for row in jsonObj["data"]:
    if row["id"].getInt == user.getId:
      result = row

proc store*(this:UserRepository, user:User) =
  let jsonObj = parseFile("user.json")
  var biggest = 0
  for key in jsonObj["data"]:
    echo key
