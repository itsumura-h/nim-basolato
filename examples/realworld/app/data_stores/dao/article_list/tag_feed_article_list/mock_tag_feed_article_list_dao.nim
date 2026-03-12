import std/asyncdispatch
import ../../../../models/dto/article_list/article_list_dto
import ../../../../models/dto/article_list/tag_feed_article_list_dao_interface

type MockTagFeedArticleListDao* = object of ITagFeedArticleListDao

proc new*(_:type MockTagFeedArticleListDao): MockTagFeedArticleListDao =
  return MockTagFeedArticleListDao()


method invoke*(self:MockTagFeedArticleListDao,tagId:string,offset:int,display:int): Future[seq[ArticleDto]]  {.async.} =
  return @[]
