import std/asyncdispatch
import std/sequtils
import allographer/query_builder
import ../../../../../database/schema
import ../../../../../config/database
import ../../../../models/dto/article_list/article_list_dto
import ../../../../models/dto/article_list/user_article_count_dao_interface


type MockUserFavoriteArticleCountDao* = object of IUserArticleCountDao

proc new*(_:type MockUserFavoriteArticleCountDao): MockUserFavoriteArticleCountDao = 
  return MockUserFavoriteArticleCountDao()


method invoke*(
  self: MockUserFavoriteArticleCountDao, 
  userId: int, 
  offset:int, 
  display:int
): Future[seq[ArticleDto]] {.async.} =
  discard
