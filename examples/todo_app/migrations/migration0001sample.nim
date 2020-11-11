import json, strformat, times
import basolato/password
import allographer/schema_builder
import allographer/query_builder

proc migration0001sample*() =
  # Create table schema
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
      Column().string("content"),
      Column().boolean("is_finished"),
      Column().timestamps()
    ], reset=true)
  ])

  # Seeder
  var users: seq[JsonNode]
  users.add(%*{
    "id": 1,
    "name": &"user1",
    "email": &"user1@nim.com",
    "password": "Password1".genHashedPassword(),
    "created_at": $(now().utc),
    "updated_at": $(now().utc),
  })
  RDB().table("users").insert(users)

  var todos: seq[JsonNode]
  todos.add(%*{
    "id": 1,
    "content": "test",
    "is_finished": false,
    "created_at": $(now().utc),
    "updated_at": $(now().utc),
  })
  RDB().table("todos").insert(todos)
