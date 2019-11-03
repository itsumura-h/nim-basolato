import json, strformat

import allographer/SchemaBuilder
import allographer/QueryBuilder


Schema().create([
  Table().create("auth", [
    Column().increments("id"),
    Column().string("name")
  ]),
  Table().create("users", [
    Column().increments("id"),
    Column().string("name").nullable(),
    Column().string("email").nullable()
  ])
])

RDB().table("auth").insert([
  %*{"name": "admin"},
  %*{"name": "user"},
])
.exec()

var users = @[%*""]
for i in 1..200:
  users.add(
    %*{"name": &"user{i}", "email": &"user{i}@gmail.com"}
  )
users.delete(0)
RDB().table("users").insert(users).exec()