import json
import allographer/query_builder

type Repository* = ref object
  rdb: RDB

proc newRepository*(db:DbConn):Repository =
  return Repository(rdb:RDB(db:db))

proc findWorld*(this:Repository, index:int) =
  discard this.rdb.table("world").findPlain(index)

proc updateRandomNumber*(this:Repository, index, number:int) =
  this.rdb.table("world").where("id", "=", index).update(%*{"randomNumber": number})
