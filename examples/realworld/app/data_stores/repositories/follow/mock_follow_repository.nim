import std/asyncdispatch
import std/options
import ../../../models/aggregates/follow/follow_entity
import ../../../models/aggregates/follow/follow_repository_interface

type MockFollowRepository* = object of IFollowRepository

proc new*(_: type MockFollowRepository): MockFollowRepository =
  return MockFollowRepository()

method isExists*(self: MockFollowRepository, follow: Follow): Future[bool] {.async.} =
  return false

method create*(self: MockFollowRepository, follow: Follow) {.async.} =
  discard

method delete*(self: MockFollowRepository, follow: Follow) {.async.} =
  discard
