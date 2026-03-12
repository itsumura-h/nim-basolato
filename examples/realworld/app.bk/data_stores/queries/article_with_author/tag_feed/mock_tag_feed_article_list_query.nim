import std/asyncdispatch
import ../../../../models/dto/article_with_author/tag_feed_article_list_query_interface
import ../../../../models/dto/article_with_author/article_with_author_dto


type MockTagFeedArticleListQuery* = object of ITagFeedArticleListQuery

proc new*(_:type MockTagFeedArticleListQuery):MockTagFeedArticleListQuery =
  return MockTagFeedArticleListQuery()


method invoke*(self:MockTagFeedArticleListQuery, tagName:string, offset:int, display:int):Future[seq[ArticleWithAuthorDto]] {.async.} =
  discard
