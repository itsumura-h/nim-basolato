import strutils
import basolato/active_record

type User = ref object of ActiveRecord

proc newUser*():RDB =
  return User.newActiveRecord()
