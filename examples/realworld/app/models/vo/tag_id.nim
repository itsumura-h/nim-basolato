import std/strutils

type TagId* = object
  value*: string

proc new*(_: type TagId, value: string): TagId =
  return TagId(value: value.toLowerAscii().replace(" ", "-"))
