import json, options
import allographer/query_builder
import query_service_interface


type QueryService* = ref object

proc newQueryService*():QueryService =
  return QueryService()


proc getPostsByUserId(self:QueryService, id:int):seq[JsonNode] =
  return rdb().table("posts").where("user_id", "=", $id).get()

proc getPostByUserId(self:QueryService, id:int):Option[JsonNode] =
  return rdb().table("posts").find(id)


proc toInterface*(self:QueryService):IQueryService =
  return (
    getPostsByUserId: proc(id:int):seq[JsonNode] = self.getPostsByUserId(id),
    getPostByUserId: proc(id:int):Option[JsonNode] = self.getPostByUserId(id)
  )
