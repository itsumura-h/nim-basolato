import json
import ../../model/value_objects
import ../../model/aggregates/user/user_entity
import allographer/query_builder


type QueryService* = ref object


proc newQueryService*():QueryService =
  return QueryService()


proc getPostsByUserId*(this:QueryService, userId:int):seq[JsonNode] =
  return rdb().table("posts").where("user_id", "=", $userId).get()

proc getPostByUserId*(this:QueryService, id:int):JsonNode =
  return rdb().table("posts").find(id)
