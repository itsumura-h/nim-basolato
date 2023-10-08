import asyncdispatch, json
import allographer/query_builder
from ../../config/database import rdb


proc group_user_map*() {.async.} =
  seeder rdb, "group_user_map":
    var data: seq[JsonNode]
    let groups = await rdb.select("id").table("groups").get()
    let users = await rdb.select("id", "name").table("users").get()
    for i, user in users:
      if 4 >= i and i >= 1:
        data.add(%*{
          "user_id": user["id"].getStr,
          "group_id": groups[0]["id"].getStr,
          "is_admin": if user["name"].getStr == "John": true else: false
        })
      elif i >= 5:
        data.add(%*{
          "user_id": user["id"].getStr,
          "group_id": groups[1]["id"].getStr,
          "is_admin": if user["name"].getStr == "Mick": true else: false
        })
    await rdb.table("group_user_map").insert(data)
