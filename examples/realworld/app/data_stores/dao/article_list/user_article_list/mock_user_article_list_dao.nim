import std/asyncdispatch
import ../../../../models/dto/article_list/article_list_dto
import ../../../../models/dto/article_list/user_article_list_dao_interface


type MockUserArticleListDao* = object of IUserArticleListDao

proc new*(_:type MockUserArticleListDao): MockUserArticleListDao = 
  return MockUserArticleListDao()


method invoke*(
  self: MockUserArticleListDao, 
  userId: int, 
  offset:int, 
  display:int
): Future[seq[ArticleDto]] {.base, async.} =
  discard
