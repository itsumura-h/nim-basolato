import json, times, asyncdispatch, options
import allographer/query_builder
import interface_implements
import ../../models/post/post_repository_interface
import ../../models/post/post_entity
import ../../models/post/post_value_objects
import ../../models/user/user_value_objects
import ../../../../database

type PostRdbRepository* = ref object


proc newPostRdbRepository*():PostRdbRepository =
  return PostRdbRepository()

implements PostRdbRepository, IPostRepository:
  proc create(self:PostRdbRepository, post:Post):Future[void] {.async.} =
    await rdb.table("posts").insert(%*{
      "title": $post.title,
      "content": $post.content,
      "is_finished": post.isFinished,
      "created_at": $post.createdAt,
      "updated_at": $post.updatedAt,
      "user_id": post.userId.getInt,
    })

  proc getPostById(self:PostRdbRepository, postId:PostId):Future[Post] {.async.} =
    let postOpt = await rdb.table("posts").where("id", "=", postId.getInt).first()
    if not postOpt.isSome:
      raise newException(Exception, "post not found")
    let data = postOpt.get
    return newPost(
      postId,
      newPostTitle(data["title"].getStr),
      newPostContent(data["content"].getStr),
      data["is_finished"].getBool,
      newUserId(data["user_id"].getInt),
    )

  proc update(self:PostRdbRepository, post:Post):Future[void] {.async.} =
    await rdb.table("posts").where("id", "=", post.postId.getInt).update(%*{
      "title": $post.title,
      "content": $post.content,
      "is_finished": post.isFinished,
      "updated_at": $post.updatedAt,
    })

  proc destroy(self:PostRdbRepository, id:PostId):Future[void] {.async.} =
    await rdb.table("posts").delete(id.getInt)
