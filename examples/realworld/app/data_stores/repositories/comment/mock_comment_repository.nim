import std/asyncdispatch
import std/options
import ../../../models/aggregates/comment/comment_entity
import ../../../models/aggregates/comment/comment_repository_interface

type MockCommentRepository* = object of ICommentRepository

proc new*(_: type MockCommentRepository): MockCommentRepository =
  return MockCommentRepository()

method getCommentById*(self: MockCommentRepository, commentId: int): Future[Option[Comment]] {.async.} =
  return none(Comment)

method create*(self: MockCommentRepository, comment: Comment) {.async.} =
  discard

method delete*(self: MockCommentRepository, commentId: int) {.async.} =
  discard
