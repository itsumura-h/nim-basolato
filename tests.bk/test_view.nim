import unittest, json
import ../src/basolato/view

suite "view":
  test "get string":
    var data = newJString("data")
    check data.get() == "data"

  test "get int":
    var data = newJInt(1)
    check data.get() == "1"

  test "get float":
    var data = newJFloat(1.1)
    check data.get() == "1.1"

  test "get int":
    var data = newJBool(true)
    check data.get() == "true"
    data = newJBool(false)
    check data.get() == "false"

  test "get null":
    var data = newJNull()
    check data.get() == ""