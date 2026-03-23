import std/asyncdispatch
import std/options
import std/json
import allographer/query_builder
from ../../../../config/database import rdb
import ../../../models/dto/favorite_button/favorite_button_dto
import ../../../models/dto/favorite_button/favorite_button_query_interface
import ../../../models/vo/article_id
import ../../../models/vo/user_id


type FavoriteButtonQuery* = object of IFavoriteButtonQuery

proc new*(_:type FavoriteButtonQuery): FavoriteButtonQuery =
  return FavoriteButtonQuery()


method invoke*(self:FavoriteButtonQuery, articleId:ArticleId, userId:UserId):Future[FavoriteButtonDto] {.async.} =
  let favoriteCount = rdb.table("user_article_map")
                          .where("article_id", "=", articleId.value)
                          .count()
                          .await

  let isFavoriteOpt = rdb.table("user_article_map")
                        .where("article_id", "=", articleId.value)
                        .where("user_id", "=", userId.value)
                        .first()
                        .await
  let isFavorited = isFavoriteOpt.isSome()

  let articleDataOpt = rdb.table("article")
                          .find(articleId.value)
                          .await
  let articleData = articleDataOpt.get()
  let isCurrentUser = articleData["author_id"].getStr == userId.value

  let dto = FavoriteButtonDto.new(articleId.value, favoriteCount, isFavorited, isCurrentUser)
  return dto


method invoke*(self:FavoriteButtonQuery, articleId:ArticleId):Future[FavoriteButtonDto] {.async.} =
  let favoriteCount = rdb.table("user_article_map")
                          .where("article_id", "=", articleId.value)
                          .count()
                          .await

  let dto = FavoriteButtonDto.new(articleId.value, favoriteCount, false,  false)
  return dto
