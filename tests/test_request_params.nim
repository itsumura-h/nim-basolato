discard """
  cmd: "nim c -d:test $file"
  matrix: "; -d:httpbeast"
"""

import std/unittest
import std/json
import ../src/basolato/core/params

when defined(htttpbeast):
  include ../src/basolato/core/libservers/nostd/request
else:
  include ../src/basolato/core/libservers/std/request

block:
  let params = Params.new()
  params["a"] = Param.new("a")
  params["one"] = Param.new("1")
  params["upload"] = Param.new("content", "filename", "jpg")
  check params.getStr("a") == "a"
  check params.getStr("one") == "1"
  check params.getInt("one") == 1
  check params.hasKey("a")
  check params.hasKey("b") == false
  check params.getAll() == %*{
    "a": {"ext": "", "fileName": "", "value": "a"},
    "one": {"ext": "", "fileName": "", "value": "1"},
    "upload": {"ext": "jpg", "fileName": "filename", "value": ""},
  }
