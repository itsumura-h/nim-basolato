import basolato/password

type UserId* = ref object
  value:int

proc newUserId*(value:int):UserId =
  result = new UserId
  result.value = value

proc getInt*(self:UserId):int =
  if self.isNil:
    return 0
  else:
    return self.value


type UserName* = ref object
  value:string

proc newUserName*(value:string):UserName =
  result = new UserName
  result.value = value

proc `$`*(self:UserName):string =
  return self.value


type UserEmail* = ref object
  value:string

proc newUserEmail*(value:string):UserEmail =
  result = new UserEmail
  result.value = value

proc `$`*(self:UserEmail):string =
  return self.value


type HashedPassword* = ref object
  value:string

proc newHashedPassword*(value:string):HashedPassword =
  result = new HashedPassword
  result.value = value

proc `$`*(self:HashedPassword):string =
  return self.value


type Password* = ref object
  value:string

proc newPassword*(value:string):Password =
  result = new Password
  result.value = value

proc `$`*(self:Password):string =
  return self.value

proc getHashed*(self:Password):HashedPassword =
  let value = self.value.genHashedPassword()
  return newHashedPassword(value)
