discard """
  cmd: "nim c -r $file"
"""

import unittest
include ../src/basolato/core/request
include ../src/basolato/view

let p = newParams()
p["a"] = Param(value:"a")
p["one"] = Param(value:"1")
p["script"] = Param(value:"<script>alert('a')</script>")

check old(p, "a") == "a"
check old(p, "c") == ""
check old(p, "c", "defualt C") == "defualt C"
check old(p, "one") == "1"
check old(p, "script") == "&lt;script&gt;alert('a')&lt;/script&gt;"
