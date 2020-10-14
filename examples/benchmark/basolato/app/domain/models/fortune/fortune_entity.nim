import ../value_objects

type Fortune* {.gcsafe.} = ref object
  id*: int
  message*: string

proc newFortune*():Fortune =
  return Fortune()
