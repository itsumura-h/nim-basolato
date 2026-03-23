import std/asyncdispatch
import ../../../../models/dto/article_list/your_feed_article_count_dao_interface


type MockYourFeedArticleCountDao* = object of IYourFeedArticleCountDao

proc new*(_:type MockYourFeedArticleCountDao):MockYourFeedArticleCountDao =
  return MockYourFeedArticleCountDao()


method invoke*(self:MockYourFeedArticleCountDao):Future[int] {.base, async.} =
  return 100
