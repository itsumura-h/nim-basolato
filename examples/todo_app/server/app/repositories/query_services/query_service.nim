import json, options
import allographer/query_builder
import interface_implements
import query_service_interface


type QueryService* = ref object

proc newQueryService*():QueryService =
  return QueryService()

implements QueryService, IQueryService:
  proc getPostsByUserId(self:QueryService, id:int):seq[JsonNode] =
    return rdb().table("posts").where("user_id", "=", $id).get()

  proc getPostById(self:QueryService, id:int):Option[JsonNode] =
    return rdb().table("posts").find(id)
