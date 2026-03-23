import std/asyncdispatch
import ../../../models/dto/user/user_query_interface
import ../../../models/dto/user/user_dto
import ../../../models/vo/user_id


type MockUserQuery* = object of IUserQuery

proc new*(_:type MockUserQuery):MockUserQuery =
  return  MockUserQuery()

method invoke*(self:MockUserQuery, userId:UserId):Future[UserDto] {.async.} =
  let dto = UserDto.new(
    userId.value,
    "user 1",
    "user1@example.com",
    "user 1, bio",
    "https://via.placeholder.com/640x480.png/000000?text=user_1",
  )
  return dto
