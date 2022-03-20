import asyncdispatch, json
import allographer/query_builder
from ../../config/database import rdb


proc status*() {.async.} =
  seeder rdb, "status":
    var data: seq[JsonNode]
    data = @[
      %*{"name": "todo"},
      %*{"name": "doing"},
      %*{"name": "done"},
    ]
    await rdb.table("status").insert(data)
