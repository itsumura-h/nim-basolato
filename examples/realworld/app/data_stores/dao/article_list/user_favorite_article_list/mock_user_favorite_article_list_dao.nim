import std/asyncdispatch
import ../../../../models/dto/article_list/article_list_dto
import ../../../../models/dto/article_list/user_article_list_dao_interface


type MockUserFavoriteArticleListDao* = object of IUserArticleListDao

proc new*(_:type MockUserFavoriteArticleListDao): MockUserFavoriteArticleListDao = 
  return MockUserFavoriteArticleListDao()


method invoke*(
  self: MockUserFavoriteArticleListDao, 
  userId: int, 
  offset:int, 
  display:int
): Future[seq[ArticleDto]] {.base, async.} =
  discard
