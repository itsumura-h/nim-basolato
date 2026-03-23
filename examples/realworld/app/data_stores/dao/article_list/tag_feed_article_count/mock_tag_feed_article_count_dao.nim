import std/asyncdispatch
import ../../../../models/dto/article_list/tag_feed_article_count_dao_interface

type MockTagFeedArticleCountDao* = object of ITagFeedArticleCountDao

proc new*(_:type MockTagFeedArticleCountDao): MockTagFeedArticleCountDao =
  return MockTagFeedArticleCountDao()


method invoke*(self:MockTagFeedArticleCountDao,tagId:string,): Future[int]  {.async.} =
  return 0
