import json, strformat

import allographer/schema_builder
import allographer/query_builder
import ../domain/entities/users_entity
import ../domain/repositories/rdb/users_repository

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

  let user = newUser(
    name="Michael Hartl",
    email="mhartl@example.com",
    password="foobar"
  )
  newUserRepository().store(user)
