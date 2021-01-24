import json
import ../../value_objects
include ../../di_container


type IPostRepository* = ref object

proc newIPostRepository*():IPostRepository =
  return newIPostRepository()


proc store*(this:IPostRepository, userId:UserId,  title:PostTitle, content:PostContent) =
  DiContainer.postRepository().store(userId, title, content)

proc changeStatus*(this:IPostRepository, id:PostId, status:bool) =
  DiContainer.postRepository().changeStatus(id, status)

proc destroy*(this:IPostRepository, id:PostId) =
  DiContainer.postRepository().destroy(id)

proc update*(this:IPostRepository, id:PostId, title:PostTitle, content:PostContent, isFinished:bool) =
  DiContainer.postRepository().update(id, title, content, isFinished)
