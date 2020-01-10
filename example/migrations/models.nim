import json, strformat

import allographer/schema_builder
import allographer/query_builder


Schema().create([
  Table().create("auth", [
    Column().increments("id"),
    Column().string("name")
  ], reset=true),
  Table().create("users", [
    Column().increments("id"),
    Column().string("name").nullable(),
    Column().string("email").nullable()
  ], reset=true)
])

RDB().table("auth").insert([
  %*{"name": "admin"},
  %*{"name": "user"},
])

var users = @[%*""]
for i in 1..200:
  users.add(
    %*{"name": &"user{i}", "email": &"user{i}@gmail.com"}
  )
users.delete(0)
RDB().table("users").insert(users)