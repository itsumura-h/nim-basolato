import std/asyncdispatch
import ../../../models/dto/user/user_dao_interface
import ../../../models/dto/user/user_dto
import ../../../models/vo/user_id


type MockUserDao* = object of IUserDao

proc new*(_:type MockUserDao):MockUserDao =
  return  MockUserDao()

method invoke*(self:MockUserDao, userId:UserId):Future[UserDto] {.async.} =
  let dto = UserDto.new(
    id = userId.value,
    name = "user 1",
    email = "user1@example.com",
    bio = "user 1, bio",
    image = "https://via.placeholder.com/640x480.png/000000?text=user_1",
    followerCount = 0
  )
  return dto
