import ../../../../../src/basolato/password

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
type HashedPassword* = ref object
  value:string

proc newHashedPassword*(value:string):HashedPassword =
  return HashedPassword(value:value)

proc get*(this:HashedPassword):string =
  return this.value

# =============================================================================
type Password* = ref object
  value:string

proc newPassword*(value:string):Password =
  if value.len < 8:
    raise newException(Exception, "Password has to be at least 8 chars")
  return Password(value:value)

proc get*(this:Password):string =
  return this.value

proc getHashed*(this:Password):HashedPassword =
  return newHashedPassword(this.value.genHashedPassword())
