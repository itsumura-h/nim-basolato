import std/asyncdispatch
import std/sequtils
import allographer/query_builder
from ../../../../../config/database import rdb
import ../../../../models/dto/article_list/article_list_dto
import ../../../../models/dto/article_list/tag_feed_article_list_dao_interface


type ArticleRow = object
  id:string
  title:string
  description:string
  createdAt:string
  authorId:string
  name:string
  image:string


type PopularUserIdRow = object
  userId:string


type TagFeedArticleListDao* = object of ITagFeedArticleListDao

proc new*(_:type TagFeedArticleListDao): TagFeedArticleListDao =
  return TagFeedArticleListDao()


method invoke*(self: TagFeedArticleListDao, tagId: string, offset: int, display: int): Future[seq[ArticleDto]] {.async.} =
  let dbArticleList = rdb.select(
                      "article.id",
                      "article.title",
                      "article.description",
                      "article.created_at as createdAt",
                      "article.author_id as authorId",
                      "user.name",
                      "user.image as image",
                    )
                    .table("article")
                    .join("user", "user.id", "=", "article.author_id")
                    .join("tag_article_map", "tag_article_map.article_id", "=", "article.id")
                    .where("tag_article_map.tag_id", "=", tagId)
                    .offset(offset)
                    .limit(display)
                    .get()
                    .orm(ArticleRow)
                    .await

  var articleList:seq[ArticleDto]
  for i, dbArticle in dbArticleList:
    let articleId = dbArticle.id

    let dbPopularUserIdList = rdb
                              .select("user_id as userId")
                              .table("user_article_map")
                              .where("article_id", "=", articleId)
                              .get()
                              .orm(PopularUserIdRow)
                              .await

    let popularUserIdList = dbPopularUserIdList.map(
      proc(row:PopularUserIdRow):string =
        return row.userId
    )

    let author = AuthorDto.new(
      id = dbArticle.authorId,
      name = dbArticle.name,
      image = dbArticle.image,
    )

    let articleTagCount = rdb.table("tag_article_map")
                              .where("article_id", "=", articleId)
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
            .where("tag_article_map.article_id", "=", articleId)
            .get()
            .orm(TagDto)
            .await
      else:
        newSeq[TagDto]()

    let article = ArticleDto.new(
      id = dbArticle.id,
      title = dbArticle.title,
      description = dbArticle.description,
      createdAt = dbArticle.createdAt,
      popularUserIdList = popularUserIdList,
      author = author,
      tagList = tagList,
    )

    articleList.add(article)

  return articleList
