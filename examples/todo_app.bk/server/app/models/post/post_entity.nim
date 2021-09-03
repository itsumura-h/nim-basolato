import json, times
import ../user/user_value_objects
import post_value_objects


type Post* = ref object
  postId:PostId
  userId:UserId
  title:PostTitle
  content:PostContent
  isFinished:bool
  createdAt: DateTime
  updatedAt: DateTime

proc postId*(self:Post):PostId =
  return self.postId

proc userId*(self:Post):UserId =
  return self.userId

proc title*(self:Post):PostTitle =
  return self.title

proc content*(self:Post):PostContent =
  return self.content

proc isFinished*(self:Post):bool =
  return self.isFinished

proc createdAt*(self:Post):DateTime =
  return self.createdAt

proc updatedAt*(self:Post):DateTime =
  return self.updatedAt

# new
proc newPost*(title:PostTitle, content:PostContent, userId:UserId):Post =
  return Post(
    title: title,
    content: content,
    isFinished: false,
    createdAt: now().utc,
    updatedAt: now().utc,
    userId: userId,
  )

# get by db
proc newPost*(postId:PostId, title:PostTitle, content:PostContent, isFinished:bool, userId:UserId):Post =
  return Post(
    postId: postId,
    title: title,
    content: content,
    isFinished: isFinished,
    userId: userId,
  )

proc done*(self:var Post) =
  self.isFinished = true

proc unDone*(self:var Post) =
  self.isFinished = false

proc updateTime*(self:var Post) =
  self.updatedAt = now().utc
