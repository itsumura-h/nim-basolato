import ../../errors


type HashedPassword*  = object
  value*:string

proc new*(_:type HashedPassword, value:string):HashedPassword =
  ## value is hashed password
  if value.len == 0:
    raise newException(DomainError, "password is empty")
  
  return HashedPassword(value:value)
