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

proc toStoreData*(this:Post):JsonNode =
  return %*{
    "user_id": this.userId.getInt(),
    "title": $this.title,
    "content": $this.content,
  }

# update
proc newPost*(postId:PostId, title:PostTitle, content:PostContent, isFinished:bool):Post =
  return Post(
    postId: postId,
    title: title,
    content: content,
    isFinished:isFinished
  )

proc toUpdateData*(this:Post):JsonNode =
  return %*{
    "post_id": this.postId.getInt(),
    "title": $this.title,
    "content": $this.content,
    "is_finished": this.isFinished
  }
