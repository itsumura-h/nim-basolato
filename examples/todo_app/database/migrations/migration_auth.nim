import asyncdispatch, json
import allographer/schema_builder
from ../../config/database import rdb


proc auth*() {.async.} =
  rdb.create(
    table("auth", [
      Column.increments("id"),
      Column.string("name")
    ])
  )
