import std/strutils
import ../../errors
import ./tag_id

type TagName*  = object
  value*:string

proc new*(_:type TagName, value:string):TagName =
  if value.len == 0:
    raise newException(IdNotFoundError, "TagName name cannot be empty")
  
  return TagName(value:value)


proc toId*(self:TagName):TagId =
  return TagId.new(self.value)
