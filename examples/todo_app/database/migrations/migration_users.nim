import asyncdispatch, json
import allographer/schema_builder
from ../../config/database import rdb


proc users*() {.async.} =
  rdb.schema(
    table("users",[
      Column().uuid("id"),
      Column().string("name"),
      Column().string("email"),
      Column().string("password"),
      Column().foreign("auth_id").reference("auth").on("id").onDelete(SET_NULL)
    ])
  )
