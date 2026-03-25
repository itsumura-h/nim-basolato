import std/json
import allographer/schema_builder
from ../../../config/database import rdb

proc createSampleTable*() =
  rdb.create([
    table("sample", [
      Column.increments("id"),
      Column.string("name"),
    ])
  ])
