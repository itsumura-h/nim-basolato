import asyncdispatch, json
import allographer/schema_builder
from ../../config/database import rdb


proc users*() {.async.} =
  rdb.create(
    table("users",[
      Column.uuid("id"),
      Column.string("name"),
      Column.string("email"),
      Column.string("password"),
      Column.foreign("auth_id").reference("auth").onTable("id").onDelete(SET_NULL)
    ])
  )
