import std/asyncdispatch
import std/json
import std/strutils
import std/random
import allographer/query_builder
import ../schema

type UserUserMap = object
  user_id: UserUserMapTable.user_id
  follower_id: UserUserMapTable.follower_id


proc userUserMap*(rdb:PostgresConnections) {.async.} =
  let users = rdb.table("user").get().orm(UserTable).await

  var data:seq[UserUserMap]
  for user in users:
    let followerCount = rand(0..users.len)
    for _ in 0..followerCount:
      while true:
        let follower = users[rand(0..<users.len)]
        if follower.id == user.id:
          continue
        data.add(
          UserUserMap(
            user_id: user.id,
            follower_id: follower.id
          )
        )
        break

  rdb.table("user_user_map").insert(data).await
