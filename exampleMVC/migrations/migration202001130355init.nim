import json, strformat, random, std/sha1

import allographer/schema_builder
import allographer/query_builder

proc migration202001130355init*() =
  schema([
    table("users", [
      Column().increments("id"),
      Column().string("name").nullable(),
      Column().string("email").nullable(),
      Column().string("password").nullable(),
    ], reset=true),
    table("posts", [
      Column().increments("id"),
      Column().string("title").nullable(),
      Column().text("text").nullable(),
      Column().datetime("created_date").default(),
      Column().datetime("published_date").nullable(),
      Column().foreign("auther_id").reference("id").on("users").onDelete(CASCADE)
    ], reset=true)
  ])

  var users: seq[JsonNode]
  for i in 1..20:
    let password = &"Password{i}"
    users.add(
      %*{
        "name": &"user{i}",
        "email": &"user{i}@gmail.com",
        "password": $password.secureHash()
      }
    )
  RDB().table("users").insert(users)

  randomize()
  var posts: seq[JsonNode]
  for i in 1..50:
    let auther_id = rand(1..20)
    posts.add(%*{
      "title": &"title{i}",
      "text": &"text{i}",
      "published_date": if i < 10: &"2020-01-0{i}" else: "",
      "auther_id": auther_id
    })
  RDB().table("posts").insert(posts)