import json, strformat, random, times

import allographer/schema_builder
import allographer/query_builder

proc migration202001130355init*() =
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
      Column().text("text").nullable(),
      Column().datetime("created_date").default(),
      Column().datetime("published_date").nullable(),
      Column().foreign("auther_id").reference("id").on("users").onDelete(CASCADE)
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
  for i in 1..20:
    let auther_id = rand(1..50)
    posts.add(%*{
      "title": &"title{i}",
      "text": &"text{i}",
      "published_date": if i < 5: &"2020-01-0{i}" else: "",
      "auther_id": auther_id
    })
  RDB().table("posts").insert(posts)