import std/asyncdispatch
import allographer/query_builder
import allographer/schema_builder


proc createTable*[T](rdb: T) {.async.} =
  rdb.create(
    table("sample", [
      Column.increments("id"),
      Column.string("name"),
    ]),
  )
