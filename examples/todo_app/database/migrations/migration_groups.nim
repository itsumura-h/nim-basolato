import asyncdispatch, json
import allographer/schema_builder
from ../../config/database import rdb


proc groups*() {.async.} =
  rdb.create(
    table("groups", [
      Column.uuid("id"),
      Column.string("name")
    ])
  )
