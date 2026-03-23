import std/asyncdispatch
import std/options
import std/strutils
import ../di_container
import ../errors
import ../models/aggregates/comment/comment_repository_interface

type DeleteCommentUsecase* = object
  repository: ICommentRepository

proc new*(_: type DeleteCommentUsecase): DeleteCommentUsecase =
  return DeleteCommentUsecase(
    repository: di.commentRepository,
  )

proc invoke*(self: DeleteCommentUsecase, userId: string, commentId: string): Future[void] {.async.} =
  let commentIdInt = parseInt(commentId)
  let commentOpt = await self.repository.getCommentById(commentIdInt)
  if commentOpt.isNone():
    raise newException(IdNotFoundError, "comment not found")
  if commentOpt.get().authorId.value != userId:
    raise newException(DomainError, "forbidden")
  await self.repository.delete(commentIdInt)
