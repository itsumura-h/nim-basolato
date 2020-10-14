import unittest, tables, json
from strutils import join
import ../src/basolato/core/header

suite "header":
  test "newHeaders":
    check newSeq[tuple[key, val:string]](0) == newHeaders()
    check newSeq[tuple[key, val:string]](1) == newHeaders(1)

  test "tuple -> header":
    let data = [
      ("key1", "value1"),
      ("key2", ["value1", "value2"].join(", "))
    ]
    let header = data.toHeaders()
    check header == @[(key: "key1", val: "value1"),(key: "key2", val: "value1, value2")]

  test "tuple -> header 2":
    let data = {
      "key1": "value1",
      "key2": ["value1", "value2"].join(", ")
    }
    let header = data.toHeaders()
    check header == @[(key: "key1", val: "value1"),(key: "key2", val: "value1, value2")]

  test "table -> header":
    let data = {
      "key1": "value1",
      "key2": ["value1", "value2"].join(", ")
    }.toTable()
    let header = data.toHeaders()
    check header[1].key == "key1"
    check header[1].val == "value1"
    check header[0].key == "key2"
    check header[0].val == "value1, value2"

  test "OrdersTable -> header":
    let data = {
      "key1": "value1",
      "key2": ["value1", "value2"].join(", ")
    }.toOrderedTable()
    let header = data.toHeaders()
    check header == @[(key: "key1", val: "value1"),(key: "key2", val: "value1, value2")]

  test "JsonNode -> header":
    let data = %*{
      "key1": "value1",
      "key2": ["value1", "value2"].join(", ")
    }
    let header = data.toHeaders()
    check header == @[(key: "key1", val: "value1"),(key: "key2", val: "value1, value2")]

  test "set":
    var header = newHeaders()
    header.set("key1", "value1")
    check header == @[(key: "key1", val: "value1")]

  test "set openarray":
    var header = newHeaders()
    header.set("key1", ["value1", "value2"])
    check header == @[(key: "key1", val: "value1, value2")]
