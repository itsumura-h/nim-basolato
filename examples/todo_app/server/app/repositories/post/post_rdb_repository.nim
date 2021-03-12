import json, times
import allographer/query_builder
import ../../core/models/post/post_repository_interface
import ../../core/models/post/post_entity
import ../../core/value_objects


type PostRdbRepository* = ref object


proc newPostRdbRepository*():PostRdbRepository =
  return PostRdbRepository()

proc store(self:PostRdbRepository, post:Post) =
  let postData = post.toStoreData()
  rdb().table("posts").insert(%*{
    "title": postData["title"].getStr,
    "content": postData["content"].getStr,
    "is_finished": false,
    "created_at": $(now().utc),
    "updated_at": $(now().utc),
    "user_id": postData["user_id"].getInt,
  })

proc changeStatus(self:PostRdbRepository, id:PostId, status:bool) =
  rdb().table("posts")
  .where("id", "=", id.getInt)
  .update(%*{
    "is_finished": status
  })

proc destroy(self:PostRdbRepository, id:PostId) =
  rdb().table("posts").delete(id.getInt)

proc update(self:PostRdbRepository, post:Post) =
  let postData = post.toUpdateData()
  rdb().table("posts")
  .where("id", "=", postData["post_id"].getInt)
  .update(%*{
    "title": postData["title"].getStr,
    "content": postData["content"].getStr,
    "is_finished": postData["is_finished"].getBool
  })

proc toInterface*(self:PostRdbRepository):IPostRepository =
  return (
    store: proc(post:Post) = self.store(post),
    changeStatus: proc(id:PostId, status:bool) = self.changeStatus(id, status),
    destroy: proc(id:PostId) = self.destroy(id),
    update: proc(post:Post) = self.update(post)
  )
