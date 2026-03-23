import std/asyncdispatch
import std/times
import std/json
import std/options
import allographer/query_builder
from ../../../../config/database import rdb
import ../../../models/aggregates/article/article_repository_interface
import ../../../models/vo/article_id
import ../../../models/aggregates/article/article_entity


type ArticleRepository* = object of IArticleRepository

proc new*(_:type ArticleRepository):ArticleRepository =
  return ArticleRepository()


method isExists*(self:ArticleRepository, articleId:ArticleId):Future[bool] {.async.} =
  let articleOpt = rdb.table("article").find(articleId.value).await
  return articleOpt.isSome()


method create*(self:ArticleRepository, article:DraftArticle) {.async.} =
  rdb.table("article").insert(%*{
    "id": article.articleId.value,
    "title": article.title.value,
    "description": article.description.value,
    "body": article.body.value,
    "author_id": article.userId.value,
    "created_at": article.createdAt.format("yyyy-MM-dd hh:mm:ss"),
    "updated_at": article.updatedAt.format("yyyy-MM-dd hh:mm:ss"),
  })
  .await

  # check tag is arleady exists
  for tag in article.tags:
    let tagOpt = rdb.table("tag").find(tag.id.value).await
    if not tagOpt.isSome():
      rdb.table("tag").insert(%*{
        "id": tag.id.value,
        "name": tag.name.value,
      })
      .await

    # if not tag is assign for article, assign
    let isAssigned = rdb.table("tag_article_map")
                        .where("tag_id", "=", tag.id.value)
                        .where("article_id", "=", article.articleId.value)
                        .first()
                        .await
    if not isAssigned.isSome():
      rdb.table("tag_article_map")
          .insert(%*{
            "tag_id": tag.id.value,
            "article_id": article.articleId.value,
          })
          .await


method update*(self:ArticleRepository, article:Article) {.async.} =
  rdb.table("article")
    .where("id", "=", article.articleId.value)
    .update(%*{
      "title": article.title.value,
      "description": article.description.value,
      "body": article.body.value,
      "updated_at": article.updatedAt.format("yyyy-MM-dd hh:mm:ss"),
    })
    .await

  let assignedTags = rdb.table("tag_article_map")
                        .where("article_id", "=", article.articleId.value)
                        .get()
                        .await

  # check tag is arleady exists
  for tag in article.tags:
    let tagOpt = rdb.table("tag").find(tag.id.value).await
    if not tagOpt.isSome():
      rdb.table("tag").insert(%*{
        "id": tag.id.value,
        "name": tag.name.value,
      })
      .await

    # if tag is assigned in DB but not in tag list, delete
    var isAssigned = false
    for assignedTag in assignedTags:
      if tag.id.value == assignedTag["tag_id"].getStr:
        isAssigned = true
        break
    if not isAssigned:
      rdb.table("tag_article_map")
          .where("tag_id", "=", tag.id.value)
          .where("article_id", "=", article.articleId.value)
          .delete()
          .await

    # if not tag is assign for article, assign
    let assignedTag = rdb.table("tag_article_map")
                        .where("tag_id", "=", tag.id.value)
                        .where("article_id", "=", article.articleId.value)
                        .first()
                        .await
    if not assignedTag.isSome():
      rdb.table("tag_article_map")
          .insert(%*{
            "tag_id": tag.id.value,
            "article_id": article.articleId.value,
          })
          .await


method delete*(self:ArticleRepository, articleId:ArticleId) {.async.} =
  rdb.table("article")
      .where("id", "=", articleId.value)  
      .delete()
      .await
