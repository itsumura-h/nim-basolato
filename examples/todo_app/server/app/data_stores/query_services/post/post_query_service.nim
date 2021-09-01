import json, options, asyncdispatch
import allographer/query_builder
import interface_implements
import ../../../usecases/post/post_query_service_interface
import ../../../../database

type PostQueryService* = ref object

proc newPostQueryService*():PostQueryService =
  result = new PostQueryService

implements PostQueryService, IPostQueryService:
  proc getPostsByUserId(self:PostQueryService, id:int):Future[seq[JsonNode]] {.async.} =
    return await rdb.table("posts").where("user_id", "=", $id).get()

  proc getPostById(self:PostQueryService, id:int):Future[Option[JsonNode]] {.async.} =
    return await rdb.table("posts").find(id)
