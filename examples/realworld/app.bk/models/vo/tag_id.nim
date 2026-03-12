import std/strutils
import ../../errors

type TagId*  = object
  value*:string

proc new*(_:type TagId, value:string):TagId =
  if value.len == 0:
    raise newException(IdNotFoundError, "TagId name cannot be empty")

  let value = value.toLowerAscii().replace(" ", "-")
  return TagId(value:value)
