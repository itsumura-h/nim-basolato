include ../../src/basolato/core/request
include ../../src/basolato/view

let params = Params()
params["a"] = Param(value:"a")
params["one"] = Param(value:"1")
params["script"] = Param(value:"<script>alert('a')</script>")

doAssert old(params, "a") == "a"
doAssert old(params, "c") == ""
doAssert old(params, "c", "defualt C") == "defualt C"
doAssert old(params, "one") == "1"
doAssert old(params, "script") == "&lt;script&gt;alert('a')&lt;/script&gt;"
