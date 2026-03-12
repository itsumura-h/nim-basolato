import std/asyncdispatch
import ../../../models/dto/tag/tag_list_query_interface
import ../../../models/dto/tag/tag_dto

type MockPopularTagListQuery* = object of ITagListQuery

proc new*(_:type MockPopularTagListQuery):MockPopularTagListQuery =
  return MockPopularTagListQuery()


method invoke*(self:MockPopularTagListQuery, count:int):Future[seq[TagDto]] {.async.} =
  discard
