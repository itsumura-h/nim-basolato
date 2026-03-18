import std/asyncdispatch
import std/options
import std/json
import std/times
import allographer/query_builder
from ../../../../config/database import rdb
import ../../../models/aggregates/article/article_entity
import ../../../models/aggregates/article/article_repository_interface
import ../../../models/aggregates/article/tag_entity
import ../../../models/vo/article_id
import ../../../models/vo/title
import ../../../models/vo/description
import ../../../models/vo/body
import ../../../models/vo/user_id
import ../../../models/vo/tag_name

type ArticleRow = object
  id: string
  title: string
  description: string
  body: string
  authorId: string

type ArticleRepository* = object of IArticleRepository

proc new*(_: type ArticleRepository): ArticleRepository =
  return ArticleRepository()

proc toTags(articleId: string): Future[seq[Tag]] {.async.} =
  let tagRows = rdb.table("tag_article_map")
    .where("article_id", "=", articleId)
    .get()
    .await
  var tags: seq[Tag] = @[]
  for row in tagRows:
    let tagId = row["tag_id"].getStr()
    let tagRow = rdb.table("tag").where("id", "=", tagId).first().await
    if tagRow.isSome():
      tags.add(Tag.new(TagName.new(tagRow.get()["name"].getStr())))
  return tags

method isExists*(self: ArticleRepository, articleId: ArticleId): Future[bool] {.async.} =
  let row = rdb.table("article").find(articleId.value).await
  return row.isSome()

method getArticleById*(self: ArticleRepository, articleId: ArticleId): Future[Option[Article]] {.async.} =
  let rowOpt = rdb
    .select(
      "id",
      "title",
      "description",
      "body",
      "author_id as authorId",
    )
    .table("article")
    .where("id", "=", articleId.value)
    .first()
    .orm(ArticleRow)
    .await
  if rowOpt.isNone():
    return none(Article)

  let row = rowOpt.get()
  let tags = await toTags(articleId.value)
  return Article.new(
    ArticleId.new(row.id),
    Title.new(row.title),
    Description.new(row.description),
    Body.new(row.body),
    tags,
    UserId.new(row.authorId),
  ).some()

method create*(self: ArticleRepository, article: DraftArticle) {.async.} =
  rdb.table("article").insert(%*{
    "id": article.articleId.value,
    "title": article.title.value,
    "description": article.description.value,
    "body": article.body.value,
    "author_id": article.userId.value,
    "created_at": article.createdAt.format("yyyy-MM-dd HH:mm:ss"),
    "updated_at": article.updatedAt.format("yyyy-MM-dd HH:mm:ss"),
  }).await

  for tag in article.tags:
    let tagOpt = rdb.table("tag").find(tag.id.value).await
    if tagOpt.isNone():
      rdb.table("tag").insert(%*{
        "id": tag.id.value,
        "name": tag.name.value,
      }).await

    rdb.table("tag_article_map").insert(%*{
      "tag_id": tag.id.value,
      "article_id": article.articleId.value,
    }).await

method update*(self: ArticleRepository, article: Article) {.async.} =
  rdb.table("article")
    .where("id", "=", article.articleId.value)
    .update(%*{
      "title": article.title.value,
      "description": article.description.value,
      "body": article.body.value,
      "updated_at": article.updatedAt.format("yyyy-MM-dd HH:mm:ss"),
    })
    .await

  rdb.table("tag_article_map")
    .where("article_id", "=", article.articleId.value)
    .delete()
    .await

  for tag in article.tags:
    let tagOpt = rdb.table("tag").find(tag.id.value).await
    if tagOpt.isNone():
      rdb.table("tag").insert(%*{
        "id": tag.id.value,
        "name": tag.name.value,
      }).await

    rdb.table("tag_article_map").insert(%*{
      "tag_id": tag.id.value,
      "article_id": article.articleId.value,
    }).await

method delete*(self: ArticleRepository, articleId: ArticleId) {.async.} =
  rdb.table("tag_article_map")
    .where("article_id", "=", articleId.value)
    .delete()
    .await
  rdb.table("user_article_map")
    .where("article_id", "=", articleId.value)
    .delete()
    .await
  rdb.table("comment")
    .where("article_id", "=", articleId.value)
    .delete()
    .await
  rdb.table("article")
    .where("id", "=", articleId.value)
    .delete()
    .await
