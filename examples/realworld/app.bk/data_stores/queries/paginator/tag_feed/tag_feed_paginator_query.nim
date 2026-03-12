import std/asyncdispatch
import allographer/query_builder
from ../../../../../config/database import rdb
import ../../../../models/dto/paginator/paginator_dto
import ../../../../models/dto/paginator/tag_feed_article_list_paginator_query_interface


type TagFeedPaginatorQuery* = object of ITagFeedArticleListPaginatorQuery

proc new*(_:type TagFeedPaginatorQuery):TagFeedPaginatorQuery =
  return TagFeedPaginatorQuery()


method invoke*(self:TagFeedPaginatorQuery, tagName:string, page:int, display:int):Future[PaginatorDto] {.async.} =
  let total = rdb.table("article")
                  .join("tag_article_map", "tag_article_map.article_id", "=", "article.id")
                  .where("tag_article_map.tag_id", "=", tagName)
                  .count().await
  let dto = PaginatorDto.new(page, display, total)
  return dto
