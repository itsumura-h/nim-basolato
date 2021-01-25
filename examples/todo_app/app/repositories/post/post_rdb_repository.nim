import json, times
import allographer/query_builder
import ../../model/aggregates/post/post_repository_interface
import ../../model/aggregates/post/post_entity
import ../../model/value_objects


type PostRdbRepository* = ref object


proc newPostRdbRepository*():PostRdbRepository =
  return PostRdbRepository()

proc store*(this:PostRdbRepository, userId:UserId, title:PostTitle, content:PostContent) =
  rdb().table("posts").insert(%*{
    "title": $title,
    "content": $content,
    "is_finished": false,
    "created_at": $(now().utc),
    "updated_at": $(now().utc),
    "user_id": userId.getInt,
  })

proc changeStatus*(this:PostRdbRepository, id:PostId, status:bool) =
  rdb().table("posts")
  .where("id", "=", id.getInt)
  .update(%*{
    "is_finished": status
  })

proc destroy*(this:PostRdbRepository, id:PostId) =
  rdb().table("posts").delete(id.getInt)

proc update*(this:PostRdbRepository, id:PostId, title:PostTitle, content:PostContent, isFinished:bool) =
  rdb().table("posts")
  .where("id", "=", id.getInt)
  .update(%*{
    "title": $title,
    "content": $content,
    "is_finished": isFinished
  })

proc toInterface*(this:PostRdbRepository):IPostRepository =
  return (
    store: proc(userId:UserId, title:PostTitle, content:PostContent) = this.store(userId, title, content),
    changeStatus: proc(id:PostId, status:bool) = this.changeStatus(id, status),
    destroy: proc(id:PostId) = this.destroy(id),
    update: proc(id:PostId, title:PostTitle, content:PostContent, isFinished:bool) = this.update(id, title, content, isFinished)
  )
