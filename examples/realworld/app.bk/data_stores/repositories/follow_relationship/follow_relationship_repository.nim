import std/asyncdispatch
import std/json
import std/options
import allographer/query_builder
from ../../../../config/database import rdb
import ../../../models/aggregates/follow_relationship/follow_relationship_repository_interface
import ../../../models/aggregates/follow_relationship/follow_relationship_entity


type FollowRelationshipRepository* = object of IFollowRelationshipRepository

proc new*(_:type FollowRelationshipRepository):FollowRelationshipRepository =
  return FollowRelationshipRepository()


method isExists*(self:FollowRelationshipRepository, relationship:FollowRelationship):Future[bool] {.async.} =
  let res = rdb.table("user_user_map")
                .where("user_id", "=", relationship.user.id.value)
                .where("follower_id", "=", relationship.follower.id.value)
                .first()
                .await
  return res.isSome()


method create*(self:FollowRelationshipRepository, relationship:FollowRelationship) {.async.} =
  rdb.table("user_user_map")
      .insert(%*{
        "user_id": relationship.user.id.value,
        "follower_id": relationship.follower.id.value,
      })
      .await


method delete*(self:FollowRelationshipRepository, relationship:FollowRelationship) {.async.} =
  rdb.table("user_user_map")
      .where("user_id", "=", relationship.user.id.value)
      .where("follower_id", "=", relationship.follower.id.value)
      .delete()
      .await
