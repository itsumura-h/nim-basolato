import std/asyncdispatch
import ../../../../models/dto/paginator/your_feed_article_list_paginator_query_interface
import ../../../../models/dto/paginator/paginator_dto
import ../../../../models/vo/user_id


type MockYourFeedPaginatorQuery* = object of IYourFeedArticleListPaginatorQuery

proc new*(_:type MockYourFeedPaginatorQuery):MockYourFeedPaginatorQuery =
  return MockYourFeedPaginatorQuery()


method invoke*(self:MockYourFeedPaginatorQuery, userId:UserId, page:int, display:int):Future[PaginatorDto] {.async.} =
  discard
