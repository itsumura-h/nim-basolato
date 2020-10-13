import ../value_objects
type World* = ref object
proc newWorld*():World =
  return World()
