import std/asyncdispatch
import std/options
import ../../../models/dto/user/user_dao_interface
import ../../../models/dto/user/user_dto


type MockUserDao* = object of IUserDao

proc new*(_:type MockUserDao):MockUserDao =
  return  MockUserDao()

method getUserById*(self:MockUserDao, userId:string, loginUserId: Option[string] = none(string)):Future[UserDto] {.async.} =
  let dto = UserDto.new(
    id = userId,
    name = "user 1",
    email = "user1@example.com",
    bio = "user 1, bio",
    image = "https://via.placeholder.com/640x480.png/000000?text=user_1",
    followerCount = 0,
    isFollowed = loginUserId.isSome(),
  )
  return dto
