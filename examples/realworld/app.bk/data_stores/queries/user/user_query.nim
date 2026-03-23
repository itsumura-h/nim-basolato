import std/asyncdispatch
import std/json
import std/options
import allographer/query_builder
import ../../../errors
from ../../../../config/database import rdb
import ../../../models/dto/user/user_query_interface
import ../../../models/dto/user/user_dto
import ../../../models/vo/user_id


type UserDbResponse = object
  id: string
  name: string
  email: string
  bio: string
  image: string


type UserQuery* = object of IUserQuery

proc new*(_:type UserQuery):UserQuery =
  return  UserQuery()

method invoke*(self:UserQuery, userId:UserId):Future[UserDto] {.async.} =
  let userDataOpt = rdb.table("user").find(userId.value).orm(UserDbResponse).await
  if not userDataOpt.isSome():
    raise newException(DomainError, "user is not found") 

  let userData = userDataOpt.get()

  let dto = UserDto.new(
    userId.value,
    userData.name,
    userData.email,
    userData.bio,
    userData.image,
  )
  return dto
