import asyncdispatch, json
import allographer/query_builder
from ../../config/database import rdb


proc auth*() {.async.} =
  seeder rdb, "auth":
    var data: seq[JsonNode]
    data = @[
      %*{"id":1, "name": "system"},
      %*{"id":2, "name": "admin"},
      %*{"id":3, "name": "member"},
    ]
    await rdb.table("auth").insert(data)
