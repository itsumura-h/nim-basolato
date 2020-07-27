import ../../../../../src/basolato/password


# =============================================================================
# User
# =============================================================================
type UserId* = ref object
  value:int

proc newUserId*(value:int):UserId =
  return UserId(value:value)

proc get*(this:UserId):int =
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


# =============================================================================
# Todo
# =============================================================================
type TodoId* = ref object
  value:int

proc newTodoId*(value:int):TodoId =
  if value < 1:
    raise newException(Exception, "TdoId should grater than 1")
  return TodoId(value:value)

proc get*(this:TodoId):int =
  return this.value

# =============================================================================
type TodoBody* = ref object
  value:string

proc newTodoBody*(value:string):TodoBody =
  if value.len < 1:
    raise newException(Exception, "Content of Todo cannot be empty")
  return TodoBody(value: value)

proc get*(this:TodoBody):string =
  return this.value
