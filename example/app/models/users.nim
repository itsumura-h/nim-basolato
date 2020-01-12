import json
import allographer/query_builder

type User* = ref object
  db: RDB

proc newUser*(): User =
  return User(
    db: RDB().table("users")
  )


proc getUsers*(this:User): seq[JsonNode] =
  this.db
    .select("users.id", "name", "email", "auth.auth")
    .join("auth", "users.auth_id", "=", "auth.id")
    .get()

proc getUser*(this:User, id:int): JsonNode =
  this.db
    .select("users.id", "name", "email", "auth.auth")
    .join("auth", "users.auth_id", "=", "auth.id")
    .find(id, key="users.id")
