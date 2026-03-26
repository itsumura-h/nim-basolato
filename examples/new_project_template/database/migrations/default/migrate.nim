import std/asyncdispatch
import allographer/schema_builder
from ../../../config/database import rdb
import ./migration_001_create_table


proc main*() =
  createTable(rdb).waitFor()


main()
createSchema(rdb).waitFor()
