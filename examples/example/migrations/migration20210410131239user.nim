import json, strformat
import allographer/schema_builder
import allographer/query_builder

proc migration20210410131239user*() =
  schema(
    table("auth", [
      Column().increments("id"),
      Column().string("auth")
    ], reset=true),
    table("users", [
      Column().increments("id"),
      Column().string("name"),
      Column().string("email"),
      Column().foreign("auth_id").reference("id").on("auth").onDelete(SET_NULL),
      Column().timestamps()
    ], reset=true)
  )

  rdb().table("auth").insert([
    %*{"id": 1, "auth": "admin"},
    %*{"id": 2, "auth": "user"},
  ])

  var users: seq[JsonNode]
  for i in 1..100:
    users.add(%*{
      "id": i,
      "name": &"user{i}",
      "email": &"user{i}@nim.com",
      "auth_id": if i mod 2 == 0: 1 else: 2
    })
  rdb().table("users").insert(users)

  echo rdb().table("users").get()
