import std/asyncdispatch
import std/options
import std/json
import allographer/query_builder
from ../../../../config/database import rdb
import ../../../models/dto/follow_button/follow_button_query_interface
import ../../../models/dto/follow_button/follow_button_dto
import ../../../models/vo/user_id


type FollowButtonQuery* = object of IFollowButtonQuery

proc new*(_:type FollowButtonQuery):FollowButtonQuery =
  return FollowButtonQuery()


method invoke*(self:FollowButtonQuery, userId:UserId, loginUserIdOpt:Option[UserId]):Future[FollowButtonDto] {.async.} =
  let followers = rdb.table("user_user_map")
                      .where("user_id", "=", userId.value)
                      .get()
                      .await

  var isFollowed = false
  if loginUserIdOpt.isSome():
    let loginUserId = loginUserIdOpt.get()
    for follower in followers.items:
      if follower["follower_id"].getStr == loginUserId.value:
        isFollowed = true
        break

  let user = rdb.table("user")
                .find(userId.value)
                .await
  let userId =
    if user.isSome():
      user.get()["id"].getStr
    else:
      ""

  let userName = 
    if user.isSome():
      user.get()["name"].getStr
    else:
      ""

  let dto = FollowButtonDto.new(userId, userName, isFollowed, followers.len)
  return dto
