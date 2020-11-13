import basolato/password


type UserName* = ref object
  value:string

proc newUserName*(value:string):UserName =
  result = new UserName
  result.value = value

proc get*(this:UserName):string =
  return this.value


type UserEmail* = ref object
  value:string

proc newUserEmail*(value:string):UserEmail =
  result = new UserEmail
  result.value = value

proc get*(this:UserEmail):string =
  return this.value


type HashedPassword* = ref object
  value:string

proc newHashedPassword*(value:string):HashedPassword =
  result = new HashedPassword
  result.value = value

proc get*(this:HashedPassword):string =
  return this.value


type Password* = ref object
  value:string

proc newPassword*(value:string):Password =
  result = new Password
  result.value = value

proc get*(this:Password):string =
  return this.value

proc getHashed*(this:Password):HashedPassword =
  let value = this.value.genHashedPassword()
  return newHashedPassword(value)
