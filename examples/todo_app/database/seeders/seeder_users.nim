import asyncdispatch, json
import allographer/query_builder
import ../../../../src/basolato/password
from ../../config/database import rdb
import ../../libs/uid


proc users*() {.async.} =
  seeder rdb, "users":
    var data: seq[JsonNode]
    data = @[
      %*{"id": genUid(), "name": "admin", "email":"admin@mail.com", "password": "adminPassword".genHashedPassword()},
      %*{"id": genUid(), "name": "John", "email":"john@beatles.com", "password": "john".genHashedPassword()},
      %*{"id": genUid(), "name": "Paul", "email":"paul@beatles.com", "password": "paul".genHashedPassword()},
      %*{"id": genUid(), "name": "George", "email":"george@beatles.com", "password": "george".genHashedPassword()},
      %*{"id": genUid(), "name": "Ringo", "email":"ringo@beatles.com", "password": "ringo".genHashedPassword()},
      %*{"id": genUid(), "name": "Mick", "email":"mick@rollingstones.com", "password": "mick".genHashedPassword()},
      %*{"id": genUid(), "name": "Keith", "email":"keith@rollingstones.com", "password": "keith".genHashedPassword()},
      %*{"id": genUid(), "name": "Brian", "email":"brian@rollingstones.com", "password": "brian".genHashedPassword()},
      %*{"id": genUid(), "name": "Ron", "email":"ron@rollingstones.com", "password": "ron".genHashedPassword()},
      %*{"id": genUid(), "name": "Bill", "email":"bill@rollingstones.com", "password": "bill".genHashedPassword()},
      %*{"id": genUid(), "name": "Charlie", "email":"charlie@rollingstones.com", "password": "charlie".genHashedPassword()}
    ]
    await rdb.table("users").insert(data)
