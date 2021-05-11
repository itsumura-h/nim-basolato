import json, options
import allographer/query_builder
import to_interface
import query_service_interface


type QueryService* = ref object

proc newQueryService*():QueryService =
  return QueryService()

bindInterface IQueryService, QueryService:
  proc getPostsByUserId(self:QueryService, id:int):seq[JsonNode] =
    return rdb().table("posts").where("user_id", "=", $id).get()

  proc getPostByUserId(self:QueryService, id:int):Option[JsonNode] =
    return rdb().table("posts").find(id)
