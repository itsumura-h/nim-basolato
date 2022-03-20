import asyncdispatch, json, parsecsv, os, strutils
import allographer/query_builder
import ../../../../src/basolato/password
from ../../config/database import rdb
import ../../libs/uid

proc users*() {.async.} =
  seeder rdb, "users":
    var data: seq[JsonNode]
    var p: CsvParser
    p.open(getCurrentDir() / "database/seeders/csv/users.csv")
    p.readHeaderRow()
    while p.readRow():
      data.add(
        %*{"id": genUid(), "name":p.row[0], "email":p.row[1], "password": p.row[2].genHashedPassword(), "auth_id": p.row[3].parseInt}
      )
    await rdb.table("users").insert(data)
