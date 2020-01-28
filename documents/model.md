Model
===
[back](../README.md)

## Introduction
Model is a layer to difine which table to connect and access database.

## Example
app/models/user.nim
```nim
import json, times
# 3rd party
import allographer/query_builder

# DI
type User* = ref object
  db: RDB

# constructor
proc newUser*(): User =
  return User(
    db: RDB().table("users")
  )


proc getUsers*(this: User): seq[JsonNode] =
  this.db.get()

proc getUser*(this: User, id:int): JsonNode =
  this.db.find(id)
```

More details of creating query is in allographer documents.  
[allographer](https://github.com/itsumura-h/nim-allographer/blob/master/documents/query_builder.md)
