import json
import allographer/QueryBuilder

type ManageUsersRepository* = ref object of RootObj

proc index*(this: ManageUsersRepository): JsonNode =
  let users = RDB().table("users").get()
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


proc show*(this: ManageUsersRepository, id: int): JsonNode =
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