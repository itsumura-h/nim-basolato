import std/asyncdispatch
import allographer/query_builder
from ../../../../../config/database import rdb
import ../../../../models/dto/article_list/tag_feed_article_count_dao_interface

type TagFeedArticleCountDao* = object of ITagFeedArticleCountDao

proc new*(_:type TagFeedArticleCountDao): TagFeedArticleCountDao =
  return TagFeedArticleCountDao()


method invoke*(self:TagFeedArticleCountDao,tagId:string,): Future[int]  {.async.} =
  let count = rdb.table("tag_article_map")
            .where("tag_article_map.tag_id", "=", tagId)
            .count()
            .await
  return count
