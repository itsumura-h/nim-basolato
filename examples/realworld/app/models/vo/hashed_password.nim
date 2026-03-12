import basolato/password
import ./password

type HashedPassword* = object
  value*:string

proc new*(_:type HashedPassword, value:string):HashedPassword =
  return HashedPassword(value: value)


proc new*(_:type HashedPassword, value:Password):HashedPassword =
  let value = genHashedPassword(value.value)
  return HashedPassword(value: value)
