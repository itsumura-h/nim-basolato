import std/asyncdispatch
import allographer/query_builder
from ../../../../../config/database import rdb
import ../../../../models/dto/article_list/user_article_count_dao_interface


type UserFavoriteArticleCountDao* = object of IUserArticleCountDao

proc new*(_:type UserFavoriteArticleCountDao):UserFavoriteArticleCountDao =
  return UserFavoriteArticleCountDao()


method invoke*(self:UserFavoriteArticleCountDao, userId:string):Future[int] {.async.} =
  let totalCount =
    rdb
    .table("user_article_map")
    .where("user_article_map.user_id", "=", userId)
    .count()
    .await
  return totalCount
