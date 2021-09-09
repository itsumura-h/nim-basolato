import asyncdispatch, json
import allographer/schema_builder
from ../../config/database import rdb


proc groups*() {.async.} =
  rdb.schema(
    table("groups", [
      Column().uuid("id"),
      Column().string("name")
    ])
  )
