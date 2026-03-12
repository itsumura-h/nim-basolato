import std/asyncdispatch
import ../../../../models/dto/paginator/paginator_dto
import ../../../../models/dto/paginator/global_feed_article_list_paginator_query_interface


type MockGlobalFeedPaginatorQuery* = object of IGlobalFeedArticleListPaginatorQuery

proc new*(_:type MockGlobalFeedPaginatorQuery):MockGlobalFeedPaginatorQuery =
  return MockGlobalFeedPaginatorQuery()


method invoke(self:MockGlobalFeedPaginatorQuery, page:int, display:int):Future[PaginatorDto] {.async.} =
  discard
