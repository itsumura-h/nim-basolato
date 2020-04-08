import bcrypt

type Id* = ref object
  value:int

proc newId*(value:int):Id =
  if value < 1:
    raise newException(Exception, "id should be an unsigned number")
  return Id(value:value)

proc get*(this:Id):int =
  return this.value
# =============================================================================
type UserName* = ref object
  value:string

proc newUserName*(value:string):UserName =
  return UserName(value:value)

proc get*(this:UserName):string =
  return this.value
# =============================================================================
type Email* = ref object
  value:string

proc newEmail*(value:string):Email =
  return Email(value:value)

proc get*(this:Email):string =
  return this.value
# =============================================================================
type Password* = ref object
  value:string

proc newPassword*(value:string):Password =
  if value.len < 6:
    raise newException(Exception, "password should at least 6 chars")
  return Password(value:value)

proc get*(this:Password):string =
  return this.value

proc getHashed*(this:Password):string =
  return this.value.hash(genSalt(8))
# =============================================================================