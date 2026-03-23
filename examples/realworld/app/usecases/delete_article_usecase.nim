import std/asyncdispatch
import std/options
import ../di_container
import ../errors
import ../models/aggregates/article/article_repository_interface
import ../models/vo/article_id

type DeleteArticleUsecase* = object
  repository: IArticleRepository

proc new*(_: type DeleteArticleUsecase): DeleteArticleUsecase =
  return DeleteArticleUsecase(
    repository: di.articleRepository,
  )

proc invoke*(self: DeleteArticleUsecase, userId, articleId: string): Future[void] {.async.} =
  let articleIdVo = ArticleId.new(articleId)
  let articleOpt = await self.repository.getArticleById(articleIdVo)
  if articleOpt.isNone():
    raise newException(IdNotFoundError, "article not found")
  if articleOpt.get().userId.value != userId:
    raise newException(DomainError, "forbidden")
  await self.repository.delete(articleIdVo)
