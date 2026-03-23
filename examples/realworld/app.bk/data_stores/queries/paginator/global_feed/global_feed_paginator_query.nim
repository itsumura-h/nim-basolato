import std/asyncdispatch
import allographer/query_builder
from ../../../../../config/database import rdb
import ../../../../models/dto/paginator/paginator_dto
import ../../../../models/dto/paginator/global_feed_article_list_paginator_query_interface


type GlobalFeedPaginatorQuery* = object of IGlobalFeedArticleListPaginatorQuery

proc new*(_:type GlobalFeedPaginatorQuery):GlobalFeedPaginatorQuery =
  return GlobalFeedPaginatorQuery()


method invoke*(self:GlobalFeedPaginatorQuery, page:int, display:int):Future[PaginatorDto] {.async.} =
  let total = rdb.table("article").count().await
  let dto = PaginatorDto.new(page, display, total)
  return dto
