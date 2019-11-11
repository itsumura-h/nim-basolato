import json
import allographer/QueryBuilder

proc index*(): JsonNode =
  let users = RDB().table("users").get()
  echo users
  var usersJson = %[]
  for user in users:
    usersJson.add(%*{
      "id": user[0],
      "name": user[1],
      "email": user[2],
      "address": user[3],
      "birth_date": user[6],
      "auth": user[7],
      "created_at": user[8],
      "updated_at": user[9]
    })
  return usersJson


proc show*(id: int): JsonNode =
  let user = RDB().table("users").find(id)
  return %*{
    "id": user[0],
    "name": user[1],
    "email": user[2],
    "address": user[3],
    "birth_date": user[6],
    "auth": user[7],
    "created_at": user[8],
    "updated_at": user[9]
  }