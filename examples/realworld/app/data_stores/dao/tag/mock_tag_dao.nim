import std/asyncdispatch
import ../../../models/dto/tag/tag_dao_interface
import ../../../models/dto/tag/tag_dto

  
type MockTagDao* = object of ITagDao

proc new*(_:type MockTagDao): MockTagDao =
  return MockTagDao()


method getPopularTagList*(self: MockTagDao): Future[seq[TagDto]] {.async.} =
  return @[]
