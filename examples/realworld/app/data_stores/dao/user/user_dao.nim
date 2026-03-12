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

method getUserById*(self:UserDao, userId:string):Future[UserDto] {.async.} =
  let userDataOpt = rdb.table("user").find(userId).orm(UserTable).await
  if not userDataOpt.isSome():
    raise newException(DomainError, "user is not found")

  let userData = userDataOpt.get()

  let followerCount = rdb.table("user_user_map")
                          .where("follower_id", "=", userId)
                          .count()
                          .await

  let dto = UserDto.new(
    id = userId,
    name = userData.name,
    email = userData.email,
    bio = userData.bio,
    image = userData.image,
    followerCount = followerCount
  )
  return dto
