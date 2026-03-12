import std/asyncdispatch
import ../../../../models/dto/article_with_author/your_feed_article_list_query_interface
import ../../../../models/dto/article_with_author/article_with_author_dto
import ../../../../models/vo/user_id


type MockYourFeedArticleListQuery* = object of IYourFeedArticleListQuery

proc new*(_:type MockYourFeedArticleListQuery):MockYourFeedArticleListQuery =
  return MockYourFeedArticleListQuery()


method invoke*(self:MockYourFeedArticleListQuery, userId:UserId, offset:int, display:int):Future[seq[ArticleWithAuthorDto]] {.async.} =
  discard
