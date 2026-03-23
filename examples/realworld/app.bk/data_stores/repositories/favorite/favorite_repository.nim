import std/asyncdispatch
import std/options
import std/json
import allographer/query_builder
from ../../../../config/database import rdb 
import ../../../models/aggregates/favorite/favorite_repository_interface
import ../../../models/aggregates/favorite/favorite_entity


type FavoriteRepository* = object of IFavoriteRepository

proc new*(_:type FavoriteRepository):FavoriteRepository =
  return FavoriteRepository()


method isExists*(self:FavoriteRepository, favorite:Favorite):Future[bool] {.async.} =
  let res = rdb.table("user_article_map")
                .where("article_id", "=", favorite.articleId.value)
                .where("user_id", "=", favorite.favoriteUserId.value)
                .first()
                .await

  return res.isSome()


method create*(self:FavoriteRepository, favorite:Favorite) {.async.} =
  rdb.table("user_article_map")
      .insert(%*{
        "article_id": favorite.articleId.value,
        "user_id": favorite.favoriteUserId.value,
      })
      .await


method delete*(self:FavoriteRepository, favorite:Favorite) {.async.} =
  rdb.table("user_article_map")
      .where("article_id", "=", favorite.articleId.value)
      .where("user_id", "=", favorite.favoriteUserId.value)
      .delete()
      .await
