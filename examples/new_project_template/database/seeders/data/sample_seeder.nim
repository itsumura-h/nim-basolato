import std/asyncdispatch
import std/json
import std/strformat
import allographer/query_builder
from ../../../config/database import rdb


proc sampleSeeder*() {.async.} =
  rdb.seeder("sample"):
    var data: seq[JsonNode]
    for i in 1..10:
      data.add(%*{
        "id": i,
        "name": &"sample{i}"
      })
    rdb.table("sample").insert(data).await
