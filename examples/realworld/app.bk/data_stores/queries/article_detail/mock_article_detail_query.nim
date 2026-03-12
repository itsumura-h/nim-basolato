import std/asyncdispatch
import ../../../models/dto/article_detail/article_detail_dto
import ../../../models/dto/article_detail/article_detail_query_interface
import ../../../models/vo/article_id


type MockArticleDetailQuery* = object of IArticleDetailQuery

proc new*(_:type MockArticleDetailQuery):MockArticleDetailQuery =
  return MockArticleDetailQuery()


method invoke*(self:MockArticleDetailQuery, articleId:ArticleId):Future[ArticleDetailDto] {.async.} =
  discard
