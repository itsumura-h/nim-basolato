import std/asyncdispatch
import std/options
import std/json
import allographer/query_builder
from ../../../../config/database import rdb
import ../../../models/dto/article_detail/article_detail_query_interface
import ../../../models/dto/article_detail/article_detail_dto
import ../../../models/vo/article_id
import ../../../errors


type ArticleDetailQuery* = object of IArticleDetailQuery

proc new*(_:type ArticleDetailQuery):ArticleDetailQuery =
  return ArticleDetailQuery()


method invoke*(self:ArticleDetailQuery, articleId:ArticleId):Future[ArticleDetailDto] {.async.} =
  let articleOpt = rdb.select(
                      "article.id",
                      "article.title",
                      "article.body",
                      "article.description",
                      "article.created_at as createdAt",
                      "article.author_id as authorId",
                      "user.name",
                      "user.image as image",
                    )
                    .table("article")
                    .join("user", "user.id", "=", "article.author_id")
                    .find(articleId.value, "article.id")
                    .await

  let articleData =
    if articleOpt.isSome():
      articleOpt.get()
    else:
      raise newException(IdNotFoundError, "Article not found")

  let articleTagCount = rdb.table("tag_article_map")
                            .where("article_id", "=", articleId.value)
                            .count()
                            .await

  let tagList =
    if articleTagCount > 0:
      rdb.select(
            "tag.id",
            "tag.name",
          )
          .table("tag")
          .join("tag_article_map", "tag_article_map.tag_id", "=", "tag.id")
          .where("tag_article_map.article_id", "=", articleId.value)
          .get()
          .orm(TagDto)
          .await
    else:
      newSeq[TagDto]()

  let followerCount = rdb.table("user_user_map")
                        .where("user_id", "=", articleData["authorId"].getStr())
                        .count()
                        .await

  let popularCount = rdb.table("user_article_map")
                          .where("article_id", "=", articleId.value)
                          .count()
                          .await

  let author = AuthorDto.new(
    id = articleData["authorId"].getStr(),
    name = articleData["name"].getStr(),
    image = articleData["image"].getStr(),
    followerCount = followerCount,
  )

  let article = ArticleDetailDto.new(
    id = articleData["id"].getStr(),
    title = articleData["title"].getStr(),
    description = articleData["description"].getStr(),
    body = articleData["body"].getStr(),
    createdAt = articleData["createdAt"].getStr(),
    popularCount = popularCount,
    author = author,
    tagList = tagList
  )

  return article
