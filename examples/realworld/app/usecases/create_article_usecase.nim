import std/asyncdispatch
import std/sequtils
import ../di_container
import ../models/aggregates/article/article_entity
import ../models/aggregates/article/article_repository_interface
import ../models/aggregates/article/tag_entity
import ../models/vo/article_id
import ../models/vo/title
import ../models/vo/description
import ../models/vo/body
import ../models/vo/user_id

type CreateArticleUsecase* = object
  repository: IArticleRepository

proc new*(_: type CreateArticleUsecase): CreateArticleUsecase =
  return CreateArticleUsecase(
    repository: di.articleRepository,
  )

proc invoke*(self: CreateArticleUsecase,
  userId, title, description, body: string,
  tags: seq[string],
): Future[string] {.async.} =
  let article = DraftArticle.new(
    Title.new(title),
    Description.new(description),
    Body.new(body),
    tags.map(proc(tagName: string): Tag = Tag.new(tagName)),
    UserId.new(userId),
  )
  await self.repository.create(article)
  return article.articleId.value
