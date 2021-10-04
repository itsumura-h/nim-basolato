import asyncdispatch, json
import allographer/schema_builder
from ../../config/database import rdb


proc status*() {.async.} =
  rdb.schema(
    table("status", [
      Column().increments("id"),
      Column().string("name")
    ])
  )
