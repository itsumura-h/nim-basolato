import std/asyncdispatch
import std/times
import std/sequtils
import allographer/query_builder
from ../../../../config/database import rdb
import ../../../../database/schema
import ../../../models/dto/comment/comment_dao_interface
import ../../../models/dto/comment/comment_dto


type CommentDb = object
  id: CommentTable.id
  body: CommentTable.body
  articleId: CommentTable.articleId
  createdAt: CommentTable.createdAt
  authorId: CommentTable.authorId
  authorName: UserTable.name
  authorImage: UserTable.image


type CommentDao* = object of ICommentDao

proc new*(_:type CommentDao): CommentDao =
  return CommentDao()


method getCommentListByArticleId*(self: CommentDao, articleId: string): Future[seq[CommentDto]] {.async.} =
  let comments =
    rdb
    .select(
      "comment.id as id",
      "comment.article_id as articleId",
      "comment.body",
      "comment.author_id as authorId",
      "comment.created_at as createdAt",
      "user.name as authorName",
      "user.image as authorImage",
    )
    .table("comment")
    .join("user", "user.id", "=", "comment.author_id")
    .where("article_id", "=", articleId)
    .orderBy("comment.created_at", Desc)
    .get()
    .orm(CommentDb)
    .await

  let commentDtoList = comments.map(
    proc(comment: CommentDb): CommentDto =
      return CommentDto.new(
        id = comment.id,
        authorId = comment.authorId,
        authorName = comment.authorName,
        authorImage = comment.authorImage,
        content = comment.body,
        createdAt = comment.createdAt.parse("yyyy-MM-dd HH:mm:ss"),
      )
  )

  return commentDtoList
