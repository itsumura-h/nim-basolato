import ../../../models/aggregates/favorite/favorite_repository_interface


type MockFavoriteRepository* = object of IFavoriteRepository

proc new*(_:type MockFavoriteRepository):MockFavoriteRepository =
  return MockFavoriteRepository()
