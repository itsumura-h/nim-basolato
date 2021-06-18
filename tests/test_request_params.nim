import unittest
include ../src/basolato/core/request

let params = newParams()
params["a"] = Param(value:"a")
params["one"] = Param(value:"1")
params["upload"] = Param(value:"content", ext:"jpg", fileName: "filename")
check params.getStr("a") == "a"
check params.getStr("one") == "1"
check params.getInt("one") == 1
check params.getAll() == %*{
  "a": {"ext": "", "fileName": "", "value": "a"},
  "one": {"ext": "", "fileName": "", "value": "1"},
  "upload": {"ext": "jpg", "fileName": "filename", "value": ""},
}