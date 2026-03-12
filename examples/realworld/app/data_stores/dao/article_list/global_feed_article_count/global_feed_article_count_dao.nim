import std/asyncdispatch
import allographer/query_builder
from ../../../../../config/database import rdb
import ../../../../models/dto/article_list/global_feed_article_count_dao_interface


type GlobalFeedArticleCountDao* = object of IGlobalFeedArticleCountDao

proc new*(_:type GlobalFeedArticleCountDao):GlobalFeedArticleCountDao =
  return GlobalFeedArticleCountDao()


method invoke*(self:GlobalFeedArticleCountDao):Future[int] {.async.} =
  let totalCount = rdb.table("article").count().await
  return totalCount
