import std/asyncdispatch
import std/options
import std/times
import ../../../models/dto/article_detail/article_detail_dto
import ../../../models/dto/article_detail/article_detail_dao_interface


type MockArticleDetailDao* = object of IArticleDetailDao

proc new*(_:type MockArticleDetailDao): MockArticleDetailDao =
  return MockArticleDetailDao()


method getArticleById*(self: MockArticleDetailDao, articleId: string, loginUserId: Option[string] = none(string)): Future[ArticleDetailDto] {.async.} =
  return ArticleDetailDto.new(
    id = articleId,
    title = "title",
    content = "content",
    createdAt = now(),
    updatedAt = now(),
    authorId = "authorId",
    favoriteCount = 0,
    isFavorited = loginUserId.isSome(),
  )
