import json
include ../../http/query_service_interface
import allographer/query_builder


type QueryService* = ref object

proc newQueryService*():QueryService =
  return QueryService()


proc getPostsByUserId(this:QueryService, id:int):seq[JsonNode] =
  return rdb().table("posts").where("user_id", "=", $id).get()

proc getPostByUserId(this:QueryService, id:int):JsonNode =
  return rdb().table("posts").find(id)


proc toInterface*(this:QueryService):IQueryService =
  return (
    getPostsByUserId: proc(id:int):seq[JsonNode] = this.getPostsByUserId(id),
    getPostByUserId: proc(id:int):JsonNode = this.getPostByUserId(id)
  )
