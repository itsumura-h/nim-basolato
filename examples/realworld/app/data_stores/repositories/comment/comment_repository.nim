import std/asyncdispatch
import std/json
import std/options
import std/times
import allographer/query_builder
from ../../../../config/database import rdb
import ../../../models/aggregates/comment/comment_entity
import ../../../models/aggregates/comment/comment_repository_interface
import ../../../models/vo/article_id
import ../../../models/vo/user_id

type CommentRepository* = object of ICommentRepository

proc new*(_: type CommentRepository): CommentRepository =
  return CommentRepository()

method getCommentById*(self: CommentRepository, commentId: int): Future[Option[Comment]] {.async.} =
  let commentOpt = rdb.table("comment")
    .where("id", "=", commentId)
    .first()
    .await
  if commentOpt.isNone():
    return none(Comment)

  let comment = commentOpt.get()
  return Comment(
    id: comment["id"].getInt(),
    articleId: ArticleId.new(comment["article_id"].getStr()),
    authorId: UserId.new(comment["author_id"].getStr()),
    body: comment["body"].getStr(),
    createdAt: comment["created_at"].getStr().parse("yyyy-MM-dd HH:mm:ss"),
    updatedAt: comment["updated_at"].getStr().parse("yyyy-MM-dd HH:mm:ss"),
  ).some()

method create*(self: CommentRepository, comment: Comment) {.async.} =
  rdb.table("comment").insert(%*{
    "body": comment.body,
    "article_id": comment.articleId.value,
    "author_id": comment.authorId.value,
    "created_at": comment.createdAt.format("yyyy-MM-dd HH:mm:ss"),
    "updated_at": comment.updatedAt.format("yyyy-MM-dd HH:mm:ss"),
  }).await

method delete*(self: CommentRepository, commentId: int) {.async.} =
  rdb.table("comment")
    .where("id", "=", commentId)
    .delete()
    .await
