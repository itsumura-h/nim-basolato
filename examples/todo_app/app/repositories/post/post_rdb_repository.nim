import json, times
import allographer/query_builder
import ../../core/models/post/post_repository_interface
import ../../core/models/post/post_entity
import ../../core/value_objects


type PostRdbRepository* = ref object


proc newPostRdbRepository*():PostRdbRepository =
  return PostRdbRepository()

proc store(this:PostRdbRepository, post:Post) =
  let postData = post.toStoreData()
  rdb().table("posts").insert(%*{
    "title": postData["title"].getStr,
    "content": postData["content"].getStr,
    "is_finished": false,
    "created_at": $(now().utc),
    "updated_at": $(now().utc),
    "user_id": postData["user_id"].getInt,
  })

proc changeStatus(this:PostRdbRepository, id:PostId, status:bool) =
  rdb().table("posts")
  .where("id", "=", id.getInt)
  .update(%*{
    "is_finished": status
  })

proc destroy(this:PostRdbRepository, id:PostId) =
  rdb().table("posts").delete(id.getInt)

proc update(this:PostRdbRepository, post:Post) =
  let postData = post.toUpdateData()
  rdb().table("posts")
  .where("id", "=", postData["post_id"].getInt)
  .update(%*{
    "title": postData["title"].getStr,
    "content": postData["content"].getStr,
    "is_finished": postData["is_finished"].getBool
  })

proc toInterface*(this:PostRdbRepository):IPostRepository =
  return (
    store: proc(post:Post) = this.store(post),
    changeStatus: proc(id:PostId, status:bool) = this.changeStatus(id, status),
    destroy: proc(id:PostId) = this.destroy(id),
    update: proc(post:Post) = this.update(post)
  )
