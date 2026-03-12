import std/asyncdispatch
import std/json
import allographer/query_builder
from ../../../../../config/database import rdb
import ../../../../models/dto/article_list/your_feed_article_list_dao_interface
import ../../../../models/dto/article_list/article_list_dto


type MockYourFeedArticleListDao* = object of IYourFeedArticleListDao

proc new*(_:type MockYourFeedArticleListDao):MockYourFeedArticleListDao =
  return MockYourFeedArticleListDao()


method invoke*(
  self:MockYourFeedArticleListDao,
  offset:int,
  display:int,
):Future[seq[ArticleDto]] {.async.} =
  return @[]
