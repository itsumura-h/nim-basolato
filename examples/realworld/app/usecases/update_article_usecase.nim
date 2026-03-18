import std/asyncdispatch
import std/options
import std/sequtils
import ../di_container
import ../errors
import ../models/aggregates/article/article_entity
import ../models/aggregates/article/article_repository_interface
import ../models/aggregates/article/tag_entity
import ../models/vo/article_id
import ../models/vo/title
import ../models/vo/description
import ../models/vo/body
import ../models/vo/user_id

type UpdateArticleUsecase* = object
  repository: IArticleRepository

proc new*(_: type UpdateArticleUsecase): UpdateArticleUsecase =
  return UpdateArticleUsecase(
    repository: di.articleRepository,
  )

proc invoke*(self: UpdateArticleUsecase,
  userId, articleId, title, description, body: string,
  tags: seq[string],
): Future[void] {.async.} =
  let articleIdVo = ArticleId.new(articleId)
  let articleOpt = await self.repository.getArticleById(articleIdVo)
  if articleOpt.isNone():
    raise newException(IdNotFoundError, "article not found")
  if articleOpt.get().userId.value != userId:
    raise newException(DomainError, "forbidden")

  let article = Article.new(
    articleIdVo,
    Title.new(title),
    Description.new(description),
    Body.new(body),
    tags.map(proc(tagName: string): Tag = Tag.new(tagName)),
    UserId.new(userId),
  )
  await self.repository.update(article)
