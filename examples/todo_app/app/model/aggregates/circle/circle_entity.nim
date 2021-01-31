import ../../value_objects


type Circle* = ref object

proc newCircle*():Circle =
  return Circle()
