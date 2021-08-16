import json, times, asyncdispatch
import allographer/query_builder
import interface_implements
import ../../core/models/post/post_repository_interface
import ../../core/models/post/post_entity
import ../../core/models/post/post_value_objects
import ../../../database

type PostRdbRepository* = ref object


proc newPostRdbRepository*():PostRdbRepository =
  return PostRdbRepository()

implements PostRdbRepository, IPostRepository:
  proc store(self:PostRdbRepository, post:Post):Future[void] {.async.} =
    let postData = post.toStoreData()
    await rdb.table("posts").insert(%*{
      "title": postData["title"].getStr,
      "content": postData["content"].getStr,
      "is_finished": false,
      "created_at": $(now().utc),
      "updated_at": $(now().utc),
      "user_id": postData["user_id"].getInt,
    })

  proc changeStatus(self:PostRdbRepository, id:PostId, status:bool):Future[void] {.async.} =
    await rdb.table("posts")
    .where("id", "=", id.getInt)
    .update(%*{
      "is_finished": status
    })

  proc destroy(self:PostRdbRepository, id:PostId):Future[void] {.async.} =
    await rdb.table("posts").delete(id.getInt)

  proc update(self:PostRdbRepository, post:Post):Future[void] {.async.} =
    let postData = post.toUpdateData()
    await rdb.table("posts")
    .where("id", "=", postData["post_id"].getInt)
    .update(%*{
      "title": postData["title"].getStr,
      "content": postData["content"].getStr,
      "is_finished": postData["is_finished"].getBool
    })
