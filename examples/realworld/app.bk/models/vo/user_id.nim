import std/strutils
import ../../errors
import ./user_name


type UserId*  = object
  value*:string = ""

proc new*(_:type UserId, value:string):UserId =
  if value.len == 0:
    raise newException(DomainError, "id is empty")

  return UserId(value:value)


proc new*(_:type UserId, userName:UserName):UserId =
  let value = userName.value.replace(".", "").replace(" ", "-")
  return UserId(value:value)

proc `==`*(a:UserId, b:UserId):bool =
  return a.value == b.value
