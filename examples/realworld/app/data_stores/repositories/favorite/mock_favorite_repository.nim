import std/asyncdispatch
import ../../../models/aggregates/favorite/favorite_entity
import ../../../models/aggregates/favorite/favorite_repository_interface

type MockFavoriteRepository* = object of IFavoriteRepository

proc new*(_: type MockFavoriteRepository): MockFavoriteRepository =
  return MockFavoriteRepository()

method isExists*(self: MockFavoriteRepository, favorite: Favorite): Future[bool] {.async.} =
  return false

method create*(self: MockFavoriteRepository, favorite: Favorite) {.async.} =
  discard

method delete*(self: MockFavoriteRepository, favorite: Favorite) {.async.} =
  discard
