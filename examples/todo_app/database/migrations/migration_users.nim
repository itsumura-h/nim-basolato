import asyncdispatch, json
import allographer/schema_builder
from ../../config/database import rdb


proc users*() {.async.} =
  rdb.schema(
    table("users",[
      Column().increments("id"),
      Column().string("name"),
      Column().string("email"),
      Column().string("password")
    ])
  )
