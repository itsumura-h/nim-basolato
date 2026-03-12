import std/asyncdispatch
import allographer/query_builder
from ../../../../../config/database import rdb
import ../../../../models/dto/article_list/your_feed_article_count_dao_interface


type YourFeedArticleCountDao* = object of IYourFeedArticleCountDao

proc new*(_:type YourFeedArticleCountDao):YourFeedArticleCountDao =
  return YourFeedArticleCountDao()


method invoke*(self:YourFeedArticleCountDao, loginUserId:string):Future[int] {.async.} =
  let totalCount =
    rdb
    .table("article")
    .join("user_article_map", "user_article_map.article_id", "=", "article.id")
    .where("user_article_map.user_id", "=", loginUserId)
    .count()
    .await
  return totalCount
