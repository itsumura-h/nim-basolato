import basolato/password
import ../../errors
import ./hashed_password


type Password*  = object
  value*:string

proc new*(_:type Password, value:string):Password =
  if value.len == 0:
    raise newException(DomainError, "password is empty")
  
  return Password(value:value)


proc hashed*(self:Password):HashedPassword =
  let hashed = genHashedPassword(self.value)
  return HashedPassword.new(hashed)
