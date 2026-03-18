import std/asyncdispatch
import std/options
import ../../../models/aggregates/article/article_entity
import ../../../models/aggregates/article/article_repository_interface
import ../../../models/vo/article_id

type MockArticleRepository* = object of IArticleRepository

proc new*(_: type MockArticleRepository): MockArticleRepository =
  return MockArticleRepository()

method isExists*(self: MockArticleRepository, articleId: ArticleId): Future[bool] {.async.} =
  return false

method getArticleById*(self: MockArticleRepository, articleId: ArticleId): Future[Option[Article]] {.async.} =
  return none(Article)

method create*(self: MockArticleRepository, article: DraftArticle) {.async.} =
  discard

method update*(self: MockArticleRepository, article: Article) {.async.} =
  discard

method delete*(self: MockArticleRepository, articleId: ArticleId) {.async.} =
  discard
