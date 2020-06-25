import json, options
import ../../../../active_records/rdb
import ../test_entity
import ../../value_objects

type TestRepository* = ref object

proc newTestRepository*():TestRepository =
  return TestRepository()
