import std/asyncdispatch
import allographer/query_builder
from ../../../../config/database import rdb
import ../../../models/dto/tag/tag_list_query_interface
import ../../../models/dto/tag/tag_dto

type PopularTagListQuery* = object of ITagListQuery

proc new*(_:type PopularTagListQuery):PopularTagListQuery =
  return PopularTagListQuery()


method invoke*(self:PopularTagListQuery, count:int):Future[seq[TagDto]] {.async.} =
  let tagList =
    rdb
    .select(
      "tag.id",
      "tag.name",
      "COUNT(id) as popularCount"
    )
    .table("tag")
    .join("tag_article_map", "tag.id", "=", "tag_article_map.tag_id")
    .groupBy("tag.id")
    .groupBy("tag.name")
    .orderBy("popularCount", Desc)
    .limit(count)
    .get()
    .orm(TagDto)
    .await

  return tagList
