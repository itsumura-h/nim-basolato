import std/asyncdispatch
import allographer/schema_builder
from ../../../config/database import rdb
import ./migration_001_create_table

proc main*() {.async.} =
  createTable().await

main().waitFor()
createSchema(rdb).waitFor()
