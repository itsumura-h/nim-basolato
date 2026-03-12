import std/asyncdispatch
import allographer/query_builder
from ../../../../../config/database import rdb
import ../../../../models/dto/paginator/user_article_list_paginator_query_interface
import ../../../../models/dto/paginator/paginator_dto
import ../../../../models/vo/user_id


type UserPaginatorQuery* = object of IUserArticleListPaginatorQuery

proc new*(_:type UserPaginatorQuery):UserPaginatorQuery =
  return UserPaginatorQuery()


method invoke*(self:UserPaginatorQuery, userId:UserId, page:int, display:int):Future[PaginatorDto] {.async.} =
  let total = rdb.table("article")
                  .where("author_id", "=", userId.value)
                  .count()
                  .await
  let dto = PaginatorDto.new(page, display, total)
  return dto
