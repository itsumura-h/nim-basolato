import ../value_objects

type Test* = ref object

proc newTest*():Test =
  return Test()
