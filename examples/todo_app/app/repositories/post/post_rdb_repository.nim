import json, times
import allographer/query_builder
import ../../model/aggregates/post/post_entity
import ../../model/value_objects


type PostRdbRepository* = ref object


proc newPostRepository*():PostRdbRepository =
  return PostRdbRepository()

proc store*(this:PostRdbRepository, userId:UserId, title:PostTitle, content:PostContent) =
  rdb().table("posts").insert(%*{
    "title": title.get(),
    "content": content.get(),
    "is_finished": false,
    "created_at": $(now().utc),
    "updated_at": $(now().utc),
    "user_id": userId.get(),
  })

proc changeStatus*(this:PostRdbRepository, id:PostId, status:bool) =
  rdb().table("posts")
    .where("id", "=", id.get())
    .update(%*{
      "is_finished": $status
    })

proc destroy*(this:PostRdbRepository, id:PostId) =
  rdb().table("posts").delete(id.get)

proc update*(this:PostRdbRepository, id:PostId, title:PostTitle, content:PostContent, isFinished:bool) =
  rdb().table("posts")
  .where("id", "=", id.get)
  .update(%*{
    "title": title.get,
    "content": content.get,
    "is_finished": isFinished
  })
