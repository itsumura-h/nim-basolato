import std/asyncdispatch
import allographer/schema_builder
from ../../config/database import rdb
import ./data/create_sample_table

proc main() =
  createSampleTable()

main()
rdb.createSchema().waitFor()
