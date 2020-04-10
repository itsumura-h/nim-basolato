import unittest, json
import allographer/schema_builder
import allographer/query_builder
import ../src/basolato/active_record

schema([
  table("samples", [
    Column().increments("id"),
    Column().string("name")
  ], reset=true)
])

RDB().table("samples").insert([
  %*{"name": "John"},
  %*{"name": "Paul"},
  %*{"name": "George"},
  %*{"name": "Ringo"},
])

suite "active record":
  test "success":
    type Sample = ref object of ActiveRecord

    proc newSample():RDB =
      return Sample.newActiveRecord()

    let sample = newSample()
    check "John" == sample.find(1)["name"].getStr
