import unittest
include ../../src/basolato/core/request

let params = Params()
params["a"] = Param(value:"a")
params["one"] = Param(value:"1")
check params.getStr("a") == "a"
check params.getStr("one") == "1"
check params.getInt("one") == 1
