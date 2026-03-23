import std/asyncdispatch
import std/json
import allographer/query_builder
from ../../../../../config/database import rdb
import ../../../../models/dto/article_with_author/tag_feed_article_list_query_interface
import ../../../../models/dto/article_with_author/article_with_author_dto


type TagFeedArticleListQuery* = object of ITagFeedArticleListQuery

proc new*(_:type TagFeedArticleListQuery):TagFeedArticleListQuery =
  return TagFeedArticleListQuery()


method invoke*(self:TagFeedArticleListQuery, tagName:string, offset:int, display:int):Future[seq[ArticleWithAuthorDto]] {.async.} =
  let articleListJson = rdb.select(
                      "article.id",
                      "article.title",
                      "article.description",
                      "article.created_at as createdAt",
                      "article.author_id",
                      "user.name",
                      "user.image as image",
                    )
                    .table("article")
                    .join("user", "user.id", "=", "article.author_id")
                    .join("tag_article_map", "tag_article_map.article_id", "=", "article.id")
                    .join("tag", "tag.id", "=", "tag_article_map.tag_id")
                    .where("tag.id", "=", tagName)
                    .offset(offset)
                    .limit(display)
                    .get()
                    .await

  var articleList:seq[ArticleWithAuthorDto]
  for i, row in articleListJson:
    let articleId = row["id"].getStr()
    let popularCount = rdb.table("user_article_map")
                          .where("article_id", "=", articleId)
                          .count()
                          .await

    let author = AuthorDto.new(
      id = row["author_id"].getStr(),
      name = row["name"].getStr(),
      image = row["image"].getStr(),
    )

    let articleTagCount = rdb.table("tag_article_map")
                              .where("article_id", "=", articleId)
                              .count()
                              .await

    let tags =
      if articleTagCount > 0:
        rdb.select(
              "tag.id",
              "tag.name",
            )
            .table("tag")
            .join("tag_article_map", "tag_article_map.tag_id", "=", "tag.id")
            .where("tag_article_map.article_id", "=", articleId)
            .get()
            .orm(TagDto)
            .await
      else:
        newSeq[TagDto]()

    let article = ArticleWithAuthorDto.new(
      id = row["id"].getStr(),
      title = row["title"].getStr(),
      description = row["description"].getStr(),
      createdAt = row["createdAt"].getStr(),
      popularCount = popularCount,
      author = author,
      tags = tags
    )

    articleList.add(article)

  return articleList
