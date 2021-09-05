import asyncdispatch, json
import allographer/query_builder
import basolato/password
from ../../config/database import rdb


proc users*() {.async.} =
  if await(rdb.table("users").count()) == 0:
    var data: seq[JsonNode]
    data = @[
      %*{"name": "admin", "email":"admin@mail.com", "password": "adminPassword".genHashedPassword()},
      %*{"name": "John", "email":"john@beatles.com", "password": "john".genHashedPassword()},
      %*{"name": "Paul", "email":"paul@beatles.com", "password": "paul".genHashedPassword()},
      %*{"name": "George", "email":"george@beatles.com", "password": "george".genHashedPassword()},
      %*{"name": "Ringo", "email":"ringo@beatles.com", "password": "ringo".genHashedPassword()},
      %*{"name": "Mick", "email":"mick@rollingstones.com", "password": "mick".genHashedPassword()},
      %*{"name": "Keith", "email":"keith@rollingstones.com", "password": "keith".genHashedPassword()},
      %*{"name": "Brian", "email":"brian@rollingstones.com", "password": "brian".genHashedPassword()},
      %*{"name": "Ron", "email":"ron@rollingstones.com", "password": "ron".genHashedPassword()},
      %*{"name": "Bill", "email":"bill@rollingstones.com", "password": "bill".genHashedPassword()},
      %*{"name": "Charlie", "email":"charlie@rollingstones.com", "password": "charlie".genHashedPassword()}
    ]
    await rdb.table("users").insert(data)
