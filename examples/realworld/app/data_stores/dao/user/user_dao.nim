import std/asyncdispatch
import std/json
import std/options
import allographer/query_builder
import ../../../errors
from ../../../../config/database import rdb
import ../../../models/dto/user/user_dao_interface
import ../../../models/dto/user/user_dto


type UserTable = object
  id: string
  name: string
  email: string
  bio: string
  image: string

type UserDao* = object of IUserDao

proc new*(_:type UserDao):UserDao =
  return  UserDao()

method getUserById*(self:UserDao, userId:string, loginUserId: Option[string] = none(string)):Future[UserDto] {.async.} =
  let userDataOpt = rdb.table("user").find(userId).orm(UserTable).await
  if not userDataOpt.isSome():
    raise newException(DomainError, "user is not found")

  let userData = userDataOpt.get()

  let followerCount = rdb.table("user_user_map")
                          .where("user_id", "=", userId)
                          .count()
                          .await

  let isFollowed =
    if loginUserId.isSome() and loginUserId.get() != userId:
      let followOpt = rdb.table("user_user_map")
                        .where("user_id", "=", userId)
                        .where("follower_id", "=", loginUserId.get())
                        .first()
                        .await
      followOpt.isSome()
    else:
      false

  let dto = UserDto.new(
    id = userId,
    name = userData.name,
    email = userData.email,
    bio = userData.bio,
    image = userData.image,
    followerCount = followerCount,
    isFollowed = isFollowed,
  )
  return dto
