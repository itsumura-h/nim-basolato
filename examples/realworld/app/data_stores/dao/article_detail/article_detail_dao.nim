import std/asyncdispatch
import std/times
import std/options
import ../../../errors
import ../../../../database/schema
import allographer/query_builder
from ../../../../config/database import rdb
import ../../../models/dto/article_detail/article_detail_dao_interface
import ../../../models/dto/article_detail/article_detail_dto


type ArticleDb* = object
  id: ArticleTable.id
  title: ArticleTable.title
  body: ArticleTable.body
  createdAt: ArticleTable.createdAt
  updatedAt: ArticleTable.updatedAt
  authorId: ArticleTable.authorId


type ArticleDetailDao* = object of IArticleDetailDao

proc new*(_:type ArticleDetailDao): ArticleDetailDao =
  return ArticleDetailDao()


method getArticleById*(self: ArticleDetailDao, articleId: string, loginUserId: Option[string] = none(string)): Future[ArticleDetailDto] {.async.} =
  let articleDeatilDb = 
    rdb
    .select(
      "id",
      "title",
      "body",
      "created_at as createdAt",
      "updated_at as updatedAt",
      "author_id as authorId"
    )
    .table("article")
    .where("id", "=", articleId)
    .first()
    .orm(ArticleDb)
    .await

  if articleDeatilDb.isNone:
    raise newException(IdNotFoundError, "Article not found")

  let articleDeatil = articleDeatilDb.get

  let favoriteCount =
    rdb
    .table("user_article_map")
    .where("article_id", "=", articleId)
    .count()
    .await

  let isFavorited =
    if loginUserId.isSome():
      let favoriteOpt = rdb
        .table("user_article_map")
        .where("article_id", "=", articleId)
        .where("user_id", "=", loginUserId.get())
        .first()
        .await
      favoriteOpt.isSome()
    else:
      false

  return ArticleDetailDto.new(
    id = articleId,
    title = articleDeatil.title,
    content = articleDeatil.body,
    createdAt = articleDeatil.createdAt.parse("yyyy-MM-dd HH:mm:ss"),
    updatedAt = articleDeatil.updatedAt.parse("yyyy-MM-dd HH:mm:ss"),
    authorId = articleDeatil.authorId,
    favoriteCount = favoriteCount,
    isFavorited = isFavorited,
  )
