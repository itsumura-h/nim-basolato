import std/asyncdispatch
import ../../../../models/dto/paginator/user_article_list_paginator_query_interface
import ../../../../models/dto/paginator/paginator_dto
import ../../../../models/vo/user_id


type MockUserPaginatorQuery* = object of IUserArticleListPaginatorQuery

proc new*(_:type MockUserPaginatorQuery):MockUserPaginatorQuery =
  return MockUserPaginatorQuery()


method invoke*(self:MockUserPaginatorQuery, userId:UserId, page:int, display:int):Future[PaginatorDto] {.async.} =
  discard
