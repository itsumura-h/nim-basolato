import std/asyncdispatch
import allographer/query_builder
from ../../../../../config/database import rdb
import ../../../../models/dto/paginator/your_feed_article_list_paginator_query_interface
import ../../../../models/dto/paginator/paginator_dto
import ../../../../models/vo/user_id


type YourFeedPaginatorQuery* = object of IYourFeedArticleListPaginatorQuery

proc new*(_:type YourFeedPaginatorQuery):YourFeedPaginatorQuery =
  return YourFeedPaginatorQuery()


method invoke*(self:YourFeedPaginatorQuery, userId:UserId, page:int, display:int):Future[PaginatorDto] {.async.} =
  let total = rdb.table("article")
                  .join("user_user_map", "user_user_map.user_id", "=", "article.author_id")
                  .where("user_user_map.follower_id", "=", userId.value)
                  .count()
                  .await
  let dto = PaginatorDto.new(page, display, total)
  return dto
