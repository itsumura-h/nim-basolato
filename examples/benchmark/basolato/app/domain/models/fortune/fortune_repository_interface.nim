import ../value_objects
include ../di_container
type IFortuneRepository* = ref object
proc newIFortuneRepository*():IFortuneRepository =
  return newIFortuneRepository()
