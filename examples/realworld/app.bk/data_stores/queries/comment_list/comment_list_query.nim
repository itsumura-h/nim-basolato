import std/asyncdispatch
import std/json
import std/options
import std/strformat
import std/sequtils
import std/times
import allographer/query_builder
from ../../../../config/database import rdb
import ../../../errors
import ../../../models/dto/comment/comment_list_query_interface
import ../../../models/dto/comment/comment_dto
import ../../../models/vo/article_id


type CommentListQuery* = object of ICommentListQuery

proc new*(_:type CommentListQuery):CommentListQuery =
  return CommentListQuery()


method invoke*(self:CommentListQuery, articleId:ArticleId):Future[seq[CommentDto]] {.async.} =
  let articleDataOpt = rdb.select(
                        "article.id",
                        "article.author_id",
                        "user.name",
                        "user.image",
                      )
                      .table("article")
                      .join("user", "user.id", "=", "author_id")
                      .find(articleId.value, "article.id")
                      .await
  
  let articleData =
    if articleDataOpt.isSome():
      articleDataOpt.get()
    else:
      raise newException(IdNotFoundError, &"articleId {articleId.value} is not found")

  let commentListData = rdb.select(
                      "comment.body",
                      "comment.created_at",
                      "user.id as userId",
                      "user.name",
                      "user.image",
                    )
                    .table("comment")
                    .where("article_id", "=", articleId.value)
                    .join("user", "user.id", "=", "comment.author_id")
                    .get()
                    .await
  
  let commentDtoList = commentListData.map(
    proc(row:JsonNode):CommentDto =
      let user = UserDto.new(
        row["userId"].getStr,
        row["name"].getStr,
        row["image"].getStr,
      )
      let comment = CommentDto.new(
        user,
        row["body"].getStr,
        row["created_at"].getStr().parse("yyyy-MM-dd hh:mm:ss")
      )
      return comment
  )

  return commentDtoList
