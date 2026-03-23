import std/asyncdispatch
import std/json
import allographer/query_builder
from ../../../../../config/database import rdb
import ../../../../models/dto/article_with_author/your_feed_article_list_query_interface
import ../../../../models/dto/article_with_author/article_with_author_dto
import ../../../../models/vo/user_id


type YourFeedArticleListQuery* = object of IYourFeedArticleListQuery

proc new*(_:type YourFeedArticleListQuery):YourFeedArticleListQuery =
  return YourFeedArticleListQuery()


method invoke*(self:YourFeedArticleListQuery, userId:UserId, offset:int, display:int):Future[seq[ArticleWithAuthorDto]] {.async.} =
  let articleListJson = rdb.select(
                          "article.id",
                          "article.title",
                          "article.description",
                          "article.created_at as createdAt",
                          "user.id as userId",
                          "user.name",
                          "user.image as image",
                        )
                        .table("article")
                        .join("user", "user.id", "=", "article.author_id")
                        .join("user_user_map", "user_user_map.user_id", "=", "article.author_id")
                        .where("user_user_map.follower_id", "=", userId.value)
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
      id = row["userId"].getStr(),
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
