include ../../src/basolato/core/request

let params = Params()
params["a"] = Param(value:"a")
params["one"] = Param(value:"1")
doAssert params.getStr("a") == "a"
doAssert params.getStr("one") == "1"
doAssert params.getInt("one") == 1
