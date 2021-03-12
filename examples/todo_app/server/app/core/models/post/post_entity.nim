import json
import ../../value_objects


type Post* = ref object
  postId:PostId
  userId:UserId
  title:PostTitle
  content:PostContent
  isFinished:bool

# store
proc newPost*(userId:UserId, title:PostTitle, content:PostContent):Post =
  return Post(
    userId: userId,
    title: title,
    content: content
  )

proc toStoreData*(self:Post):JsonNode =
  return %*{
    "user_id": self.userId.getInt(),
    "title": $self.title,
    "content": $self.content,
  }

# update
proc newPost*(postId:PostId, title:PostTitle, content:PostContent, isFinished:bool):Post =
  return Post(
    postId: postId,
    title: title,
    content: content,
    isFinished:isFinished
  )

proc toUpdateData*(self:Post):JsonNode =
  return %*{
    "post_id": self.postId.getInt(),
    "title": $self.title,
    "content": $self.content,
    "is_finished": self.isFinished
  }
