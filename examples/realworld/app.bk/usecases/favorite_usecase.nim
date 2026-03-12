import std/asyncdispatch
import ..//di_container
import ../models/vo/article_id
import ../models/vo/user_id
import ../models/aggregates/favorite/favorite_entity
import ../models/aggregates/favorite/favorite_repository_interface


type FavoriteUsecase* = object
  repository: IFavoriteRepository


proc new*(_:type FavoriteUsecase):FavoriteUsecase =
  return FavoriteUsecase(
    repository: di.favoriteRepository
  )


proc invoke*(self:FavoriteUsecase, articleId:string, favoriteUserId:string) {.async.} =
  let articleId = ArticleId.new(articleId)
  let favoriteUserId = UserId.new(favoriteUserId)
  let favorite = Favorite.new(articleId, favoriteUserId)

  if not self.repository.isExists(favorite).await:
    self.repository.create(favorite).await
  else:
    self.repository.delete(favorite).await
