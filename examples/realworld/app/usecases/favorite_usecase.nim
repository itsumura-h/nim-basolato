import std/asyncdispatch
import ../di_container
import ../models/aggregates/favorite/favorite_entity
import ../models/aggregates/favorite/favorite_repository_interface
import ../models/vo/article_id
import ../models/vo/user_id

type FavoriteUsecase* = object
  repository: IFavoriteRepository

proc new*(_: type FavoriteUsecase): FavoriteUsecase =
  return FavoriteUsecase(
    repository: di.favoriteRepository,
  )

proc invoke*(self: FavoriteUsecase, articleId: string, favoriteUserId: string): Future[void] {.async.} =
  let favorite = Favorite.new(ArticleId.new(articleId), UserId.new(favoriteUserId))
  if self.repository.isExists(favorite).await:
    await self.repository.delete(favorite)
  else:
    await self.repository.create(favorite)
