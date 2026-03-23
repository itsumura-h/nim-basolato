import ../../errors

type Body* = object
  value*:string

proc new*(_:type Body, value:string):Body =
  if value.len == 0:
    raise newException(DomainError, "Body cannot be empty")
  return Body(value:value)
