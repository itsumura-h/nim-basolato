import strutils
# framework
import ../../../../src/basolato/active_record
# 3rd patry
import allographer/query_builder

export query_builder


type User = ref object of ActiveRecord

proc newUser*():RDB =
  return User.newActiveRecord()
