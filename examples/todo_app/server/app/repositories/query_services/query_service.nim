import json, options, asyncdispatch
import allographer/query_builder
import interface_implements
import query_service_interface
import ../../../database


type QueryService* = ref object

proc newQueryService*():QueryService =
  return QueryService()

implements QueryService, IQueryService:
  proc getPostsByUserId(self:QueryService, id:int):Future[seq[JsonNode]] {.async.} =
    return await rdb.table("posts").where("user_id", "=", $id).get()

  proc getPostById(self:QueryService, id:int):Future[Option[JsonNode]] {.async.} =
    return await rdb.table("posts").find(id)
