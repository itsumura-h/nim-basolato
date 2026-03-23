import std/asyncdispatch
import ../../../../models/dto/article_with_author/user_article_list_query_interface
import ../../../../models/dto/article_with_author/article_with_author_dto
import ../../../../models/vo/user_id


type MockUserArticleListQuery* = object of IUserArticleListQuery

proc new*(_:type MockUserArticleListQuery):MockUserArticleListQuery =
  return MockUserArticleListQuery()


method invoke*(self:MockUserArticleListQuery, userId:UserId, offset:int, display:int):Future[seq[ArticleWithAuthorDto]] {.async.} =
  discard
