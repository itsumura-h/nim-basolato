import ../../errors

type UserName*  = object
  value*:string

proc new*(_:type UserName, value:string):UserName =
  if value.len == 0:
    raise newException(DomainError, "user name is empty")
  
  return UserName(value:value)
