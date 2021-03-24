import unittest
include ../../src/basolato/core/request
include ../../src/basolato/view

let params = Params()
params["a"] = Param(value:"a")
params["one"] = Param(value:"1")
params["script"] = Param(value:"<script>alert('a')</script>")

check old(params, "a") == "a"
check old(params, "c") == ""
check old(params, "c", "defualt C") == "defualt C"
check old(params, "one") == "1"
check old(params, "script") == "&lt;script&gt;alert('a')&lt;/script&gt;"
