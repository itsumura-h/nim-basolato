import basolato/core/validation
import ../../errors


type Email*  = object
  value:string

proc new*(_:type Email, value:string):Email =
  if value.len == 0:
    raise newException(DomainError, "email is empty")

  let validation = newValidation()
  if not validation.email(value):
    raise newException(DomainError, "email is invalid")
  
  return Email(value:value)

proc value*(self:Email):string =
  return self.value
