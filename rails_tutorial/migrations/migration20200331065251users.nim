import json, strformat

import allographer/schema_builder
import allographer/query_builder
import ../app/models/users

proc migration20200331065251users*() =
  schema([
    table("users", [
      Column().increments("id"),
      Column().string("name"),
      Column().string("email").unique(),
      Column().string("password_digest"),
      Column().timestamps()
    ], reset=true)
  ])

  newUser(
    name="Michael Hartl",
    email="mhartl@example.com",
    password="foobar"
  ).save()
