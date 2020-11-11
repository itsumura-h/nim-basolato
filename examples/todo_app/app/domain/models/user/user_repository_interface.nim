import ../value_objects
include ../di_container


type IUserRepository* = ref object


proc newIUserRepository*():IUserRepository =
  return newIUserRepository()
