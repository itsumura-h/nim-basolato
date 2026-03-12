import std/asyncdispatch
import std/json
import allographer/query_builder
from ../../../../../config/database import rdb
import ../../../../models/dto/article_list/global_feed_article_list_dao_interface
import ../../../../models/dto/article_list/article_list_dto


type MockGlobalFeedArticleListDao* = object of IGlobalFeedArticleListDao

proc new*(_:type MockGlobalFeedArticleListDao):MockGlobalFeedArticleListDao =
  return MockGlobalFeedArticleListDao()


method invoke*(
  self:MockGlobalFeedArticleListDao,
  offset:int,
  display:int,
):Future[seq[ArticleDto]] {.async.} =
  discard
