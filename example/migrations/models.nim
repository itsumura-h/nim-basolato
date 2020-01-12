import json, strformat, random

import allographer/schema_builder
import allographer/query_builder


Schema().create([
  Table().create("auth", [
    Column().increments("id"),
    Column().string("auth")
  ], reset=true),
  Table().create("users", [
    Column().increments("id"),
    Column().string("name").nullable(),
    Column().string("email").nullable(),
    Column().foreign("auth_id").reference("id").on("auth").onDelete(SET_NULL)
  ], reset=true),
  Table().create("posts", [
    Column().increments("id"),
    Column().string("title").nullable(),
    Column().text("post").nullable(),
    Column().foreign("user_id").reference("id").on("users").onDelete(SET_NULL)
  ], reset=true)
])

RDB().table("auth").insert([
  %*{"auth": "admin"},
  %*{"auth": "user"}
])

var users: seq[JsonNode]
for i in 1..50:
  let authId = if i mod 2 == 0: 2 else: 1
  users.add(
    %*{
      "name": &"user{i}",
      "email": &"user{i}@gmail.com",
      "auth_id": authId
    }
  )
RDB().table("users").insert(users)

randomize()
var posts: seq[JsonNode]
for i in 1..100:
  let userId = rand(1..50)
  posts.add(
    %*{
      "title": &"post{i} user{userId}",
      "post": &"post{i} user{userId}",
      "user_id": userId
    }
  )
RDB().table("posts").insert(posts)
