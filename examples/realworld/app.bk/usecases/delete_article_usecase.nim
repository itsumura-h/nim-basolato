import std/asyncdispatch
import ../di_container
import ../errors
import ../models/aggregates/article/article_repository_interface
import ../models/vo/article_id


type DeleteArticleUsecase* = object
  repository:IArticleRepository

proc new*(_:type DeleteArticleUsecase):DeleteArticleUsecase =
  return DeleteArticleUsecase(
    repository: di.articleRepository
  )


proc invoke*(self:DeleteArticleUsecase, articleId:string) {.async.} =
  let articleId = ArticleId.new(articleId)
  if not self.repository.isExists(articleId).await:
    raise newException(IdNotFoundError, "article not found")

  self.repository.delete(articleId).await
