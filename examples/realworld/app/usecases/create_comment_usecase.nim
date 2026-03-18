import std/asyncdispatch
import ../di_container
import ../models/aggregates/comment/comment_entity
import ../models/aggregates/comment/comment_repository_interface
import ../models/vo/article_id
import ../models/vo/user_id

type CreateCommentUsecase* = object
  repository: ICommentRepository

proc new*(_: type CreateCommentUsecase): CreateCommentUsecase =
  return CreateCommentUsecase(
    repository: di.commentRepository,
  )

proc invoke*(self: CreateCommentUsecase, articleId, authorId, body: string): Future[void] {.async.} =
  let comment = Comment.new(ArticleId.new(articleId), UserId.new(authorId), body)
  await self.repository.create(comment)
