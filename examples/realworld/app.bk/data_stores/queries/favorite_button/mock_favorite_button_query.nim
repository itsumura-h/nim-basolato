import std/asyncdispatch
import ../../../models/dto/favorite_button/favorite_button_dto
import ../../../models/dto/favorite_button/favorite_button_query_interface
import ../../../models/vo/article_id
import ../../../models/vo/user_id


type MockFavoriteButtonQuery* = object of IFavoriteButtonQuery

proc new*(_:type MockFavoriteButtonQuery): MockFavoriteButtonQuery =
  return MockFavoriteButtonQuery()


method invoke*(self:MockFavoriteButtonQuery, articleId:ArticleId, userId:UserId):Future[FavoriteButtonDto] {.async.} =
  discard


method invoke*(self:MockFavoriteButtonQuery, articleId:ArticleId):Future[FavoriteButtonDto] {.async.} =
  discard
