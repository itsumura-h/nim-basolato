discard """
  cmd: "nim c -r $file"
  matrix: "; -d:httpbeast"
"""

import std/unittest
import ../src/basolato/view

when defined(httpbeast):
  include ../src/basolato/core/libservers/nostd/request
else:
  include ../src/basolato/core/libservers/std/request

let p = Params.new()
p["a"] = Param(value:"a")
p["one"] = Param(value:"1")
p["script"] = Param(value:"<script>alert('a')</script>")

check old(p, "a") == "a"
check old(p, "c") == ""
check old(p, "c", "defualt C") == "defualt C"
check old(p, "one") == "1"
check old(p, "script") == "<script>alert('a')</script>"
