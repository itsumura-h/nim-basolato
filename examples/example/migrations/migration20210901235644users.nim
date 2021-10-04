import asyncdispatch, json, strformat
import allographer/schema_builder
import allographer/query_builder
from ../database import rdb


proc migration20210901235644users*() {.async.} =
  rdb.schema(
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

  if await(rdb.table("auth").count()) == 0:
    await rdb.table("auth").insert(@[
      %*{"id": 1, "auth": "admin"},
      %*{"id": 2, "auth": "user"},
    ])

  if await(rdb.table("users").count()) == 0:
    var users: seq[JsonNode]
    for i in 1..100:
      users.add(%*{
        "id": i,
        "name": &"user{i}",
        "email": &"user{i}@nim.com",
        "auth_id": if i mod 2 == 0: 1 else: 2
      })
    await rdb.table("users").insert(users)

  echo await(rdb.table("users").get())

