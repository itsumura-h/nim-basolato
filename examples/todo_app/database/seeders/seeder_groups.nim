import asyncdispatch, json, options, oids
import allographer/query_builder
from ../../config/database import rdb


proc groups*() {.async.} =
  seeder rdb, "groups":
    var data: seq[JsonNode]
    data = @[
      %*{
        "id": $genOid(),
        "name": "Beatles",
      },
      %*{
        "id": $genOid(),
        "name": "Rolling Stones",
      }
    ]
    await rdb.table("groups").insert(data)
