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


type PostId* = ref object
  value:int

proc newPostId*(value:int):PostId =
  if value < 1:
    raise newException(Exception, "id should be unsigned")
  result = new PostId
  result.value = value

proc get*(this:PostId):int =
  return this.value


type PostTitle* = ref object
  value:string

proc newPostTitle*(value:string):PostTitle =
  if value.len == 0:
    raise newException(Exception, "title is not allowed empty")
  result = new PostTitle
  result.value = value

proc get*(this:PostTitle):string =
  return this.value


type PostContent* = ref object
  value:string

proc newPostContent*(value:string):PostContent =
  if value.len == 0:
    raise newException(Exception, "content is not allowed empty")
  result = new PostContent
  result.value = value

proc get*(this:PostContent):string =
  return this.value
