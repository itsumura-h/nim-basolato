import ../../../../active_records/rdb
import ../user_entity
import ../../value_objects

type UserRepository* = ref object

proc newUserRepository*():UserRepository =
  return UserRepository()
