import unittest, json
import allographer/schema_builder
import allographer/query_builder
import ../src/basolato/model

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

suite "model":
  test "success":
    type Sample = ref object of Model

    proc newSample():Sample =
      return Sample.newModel()

    let sample = newSample()
    check "John" == sample.db.find(1)["name"].getStr
