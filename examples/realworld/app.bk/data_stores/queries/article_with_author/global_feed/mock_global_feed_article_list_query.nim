import std/asyncdispatch
import ../../../../models/dto/article_with_author/global_feed_article_list_query_interface
import ../../../../models/dto/article_with_author/article_with_author_dto


type MockGlobalFeedArticleListQuery* = object of IGlobalFeedArticleListQuery

proc new*(_:type MockGlobalFeedArticleListQuery):MockGlobalFeedArticleListQuery =
  return MockGlobalFeedArticleListQuery()


method invoke*(
  self:MockGlobalFeedArticleListQuery,
  offset:int,
  display:int
):Future[seq[ArticleWithAuthorDto]] {.async.} =
  discard
