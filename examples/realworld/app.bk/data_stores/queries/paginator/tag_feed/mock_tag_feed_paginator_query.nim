import std/asyncdispatch
import ../../../../models/dto/paginator/paginator_dto
import ../../../../models/dto/paginator/tag_feed_article_list_paginator_query_interface

type MockTagFeedPaginatorQuery* = object of ITagFeedArticleListPaginatorQuery

proc new*(_:type MockTagFeedPaginatorQuery):MockTagFeedPaginatorQuery =
  return MockTagFeedPaginatorQuery()


method invoke*(self:MockTagFeedPaginatorQuery, tagName:string, page:int, display:int):Future[PaginatorDto] {.async.} =
  discard
