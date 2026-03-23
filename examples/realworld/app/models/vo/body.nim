type Body* = object
  value*: string

proc new*(_: type Body, value: string): Body =
  return Body(value: value)
