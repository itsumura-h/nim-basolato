import asyncdispatch, json, oids
import allographer/query_builder
import ../../../../src/basolato/password
from ../../config/database import rdb


proc users*() {.async.} =
  seeder rdb, "users":
    var data: seq[JsonNode]
    data = @[
      %*{"id": $genOid(), "name": "admin", "email":"admin@mail.com", "password": "adminPassword".genHashedPassword()},
      %*{"id": $genOid(), "name": "John", "email":"john@beatles.com", "password": "john".genHashedPassword()},
      %*{"id": $genOid(), "name": "Paul", "email":"paul@beatles.com", "password": "paul".genHashedPassword()},
      %*{"id": $genOid(), "name": "George", "email":"george@beatles.com", "password": "george".genHashedPassword()},
      %*{"id": $genOid(), "name": "Ringo", "email":"ringo@beatles.com", "password": "ringo".genHashedPassword()},
      %*{"id": $genOid(), "name": "Mick", "email":"mick@rollingstones.com", "password": "mick".genHashedPassword()},
      %*{"id": $genOid(), "name": "Keith", "email":"keith@rollingstones.com", "password": "keith".genHashedPassword()},
      %*{"id": $genOid(), "name": "Brian", "email":"brian@rollingstones.com", "password": "brian".genHashedPassword()},
      %*{"id": $genOid(), "name": "Ron", "email":"ron@rollingstones.com", "password": "ron".genHashedPassword()},
      %*{"id": $genOid(), "name": "Bill", "email":"bill@rollingstones.com", "password": "bill".genHashedPassword()},
      %*{"id": $genOid(), "name": "Charlie", "email":"charlie@rollingstones.com", "password": "charlie".genHashedPassword()}
    ]
    await rdb.table("users").insert(data)
