import json, strformat
import bcrypt

import allographer/schema_builder
import allographer/query_builder
import ../app/models/users

proc migration20200331065251users*() =
  schema([
    table("users", [
      Column().increments("id"),
      Column().string("name"),
      Column().string("email").unique(),
      Column().string("password"),
      Column().timestamps()
    ], reset=true)
  ])

  newUser().store(
    name="Michael Hartl",
    email="mhartl@example.com",
    password="foobar".hash(genSalt(10))
  )
