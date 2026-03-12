import std/asyncdispatch
import ../../../../models/dto/article_list/global_feed_article_count_dao_interface


type MockGlobalFeedArticleCountDao* = object of IGlobalFeedArticleCountDao

proc new*(_:type MockGlobalFeedArticleCountDao):MockGlobalFeedArticleCountDao =
  return MockGlobalFeedArticleCountDao()


method invoke*(self:MockGlobalFeedArticleCountDao):Future[int] {.async.} =
  return 100
