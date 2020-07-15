import json, strformat
import ../../../src/basolato/baseEnv
import ../../../src/basolato/password
import allographer/schema_builder
import allographer/query_builder
import faker

proc migration20200617151816users_todo*() =
  schema([
    table("users", [
      Column().increments("id"),
      Column().string("name"),
      Column().string("email"),
      Column().string("password"),
      Column().timestamps()
    ], reset=true),
    table("todos", [
      Column().increments("id"),
      Column().string("todo"),
      Column().foreign("user_id").reference("id").on("users").onDelete(SET_NULL)
    ], reset=true)
  ])

  var users = newSeq[JsonNode]()
  for i in 1..5:
    let name = &"user{i}"
    users.add(%*{
      "name": name,
      "email": &"{name}@gmail.com",
      "password": genHashedPassword(&"{name}Password")
    })
  RDB().table("users").insert(users)
