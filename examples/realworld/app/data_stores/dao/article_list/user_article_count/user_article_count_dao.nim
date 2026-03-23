import std/asyncdispatch
import allographer/query_builder
from ../../../../../config/database import rdb
import ../../../../models/dto/article_list/user_article_count_dao_interface


type UserArticleCountDao* = object of IUserArticleCountDao

proc new*(_:type UserArticleCountDao):UserArticleCountDao =
  return UserArticleCountDao()


method invoke*(self:UserArticleCountDao, userId:string):Future[int] {.async.} =
  let totalCount =
    rdb
    .table("article")
    .where("author_id", "=", userId)
    .count()
    .await
  return totalCount
