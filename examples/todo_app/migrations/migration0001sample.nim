import json, strformat, times
import ../../../src/basolato/password
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
      Column().string("title"),
      Column().text("content"),
      Column().boolean("is_finished"),
      Column().timestamps(),
      Column().foreign("user_id").reference("id").on("users").onDelete(CASCADE)
    ], reset=true)
  ])

  # Seeder
  var users: seq[JsonNode]
  for i in 1..10:
    users.add(%*{
      "id": i,
      "name": &"user{i}",
      "email": &"user{i}@nim.com",
      "password": genHashedPassword(&"Password{i}"),
      "created_at": $(now().utc),
      "updated_at": $(now().utc),
    })
  rdb().table("users").insert(users)

  var todos: seq[JsonNode]
  todos.add(%*{
    "id": 1,
    "title": "test",
    "content": "test content",
    "is_finished": false,
    "created_at": $(now().utc),
    "updated_at": $(now().utc),
    "user_id": 1
  })
  rdb().table("todos").insert(todos)
