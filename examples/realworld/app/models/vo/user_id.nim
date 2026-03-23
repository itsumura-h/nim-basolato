import ../../errors
import ../../libs/uuid


type UserId*  = object
  value*:string = ""

proc new*(_:type UserId):UserId =
  return UserId(value:genUuid())


proc new*(_:type UserId, value:string):UserId =
  if value.len == 0:
    raise newException(DomainError, "id is empty")

  return UserId(value:value)


proc `==`*(a:UserId, b:UserId):bool =
  return a.value == b.value
