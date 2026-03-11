discard """
  cmd: "nim c -d:test $file"
  matrix: "; -d:httpbeast"
"""

import std/unittest
import ../src/basolato/view

block:
  let p = Params.new()
  p["a"] = Param.new("a")
  p["one"] = Param.new("1")
  p["script"] = Param.new("<script>alert('a')</script>")

  check old(p, "a") == "a"
  check old(p, "c") == ""
  check old(p, "c", "defualt C") == "defualt C"
  check old(p, "one") == "1"
  check old(p, "script") == "<script>alert('a')</script>"
