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


type PostId* = ref object
  value:int

proc newPostId*(value:int):PostId =
  if value < 1:
    raise newException(Exception, "id should be unsigned")
  result = new PostId
  result.value = value

proc getInt*(self:PostId):int =
  return self.value


type PostTitle* = ref object
  value:string

proc newPostTitle*(value:string):PostTitle =
  if value.len == 0:
    raise newException(Exception, "title is not allowed empty")
  result = new PostTitle
  result.value = value

proc `$`*(self:PostTitle):string =
  return self.value


type PostContent* = ref object
  value:string

proc newPostContent*(value:string):PostContent =
  if value.len == 0:
    raise newException(Exception, "content is not allowed empty")
  result = new PostContent
  result.value = value

proc `$`*(self:PostContent):string =
  return self.value
