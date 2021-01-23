import basolato/password

type UserId* = ref object
  value:int

proc newUserId*(value:int):UserId =
  result = new UserId
  result.value = value

proc get*(this:UserId):int =
  return this.value


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


type TodoId* = ref object
  value:int

proc newTodoId*(value:int):TodoId =
  if value < 1:
    raise newException(Exception, "id should be unsigned")
  result = new TodoId
  result.value = value

proc get*(this:TodoId):int =
  return this.value


type TodoTitle* = ref object
  value:string

proc newTodoTitle*(value:string):TodoTitle =
  if value.len == 0:
    raise newException(Exception, "title is not allowed empty")
  result = new TodoTitle
  result.value = value

proc get*(this:TodoTitle):string =
  return this.value


type TodoContent* = ref object
  value:string

proc newTodoContent*(value:string):TodoContent =
  if value.len == 0:
    raise newException(Exception, "content is not allowed empty")
  result = new TodoContent
  result.value = value

proc get*(this:TodoContent):string =
  return this.value
