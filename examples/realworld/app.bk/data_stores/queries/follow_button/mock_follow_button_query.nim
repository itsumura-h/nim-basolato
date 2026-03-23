import std/asyncdispatch
import std/options
import ../../../models/dto/follow_button/follow_button_query_interface
import ../../../models/dto/follow_button/follow_button_dto
import ../../../models/vo/user_id


type MockFollowButtonQuery* = object of IFollowButtonQuery

proc new*(_:type MockFollowButtonQuery):MockFollowButtonQuery =
  return MockFollowButtonQuery()


method invoke*(self:MockFollowButtonQuery, userId:UserId, loginUserIdOpt:Option[UserId]):Future[FollowButtonDto] {.async.} =
  discard
