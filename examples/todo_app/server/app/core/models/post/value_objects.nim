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
