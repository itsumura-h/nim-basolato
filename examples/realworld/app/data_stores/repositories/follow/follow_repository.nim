import std/asyncdispatch
import std/options
import std/json
import allographer/query_builder
from ../../../../config/database import rdb
import ../../../models/aggregates/follow/follow_entity
import ../../../models/aggregates/follow/follow_repository_interface

type FollowRepository* = object of IFollowRepository

proc new*(_: type FollowRepository): FollowRepository =
  return FollowRepository()

method isExists*(self: FollowRepository, follow: Follow): Future[bool] {.async.} =
  let row = rdb.table("user_user_map")
    .where("user_id", "=", follow.userId.value)
    .where("follower_id", "=", follow.followerId.value)
    .first()
    .await
  return row.isSome()

method create*(self: FollowRepository, follow: Follow) {.async.} =
  rdb.table("user_user_map").insert(%*{
    "user_id": follow.userId.value,
    "follower_id": follow.followerId.value,
  }).await

method delete*(self: FollowRepository, follow: Follow) {.async.} =
  rdb.table("user_user_map")
    .where("user_id", "=", follow.userId.value)
    .where("follower_id", "=", follow.followerId.value)
    .delete()
    .await
