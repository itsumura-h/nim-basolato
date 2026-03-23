import std/asyncdispatch
import ../../http/views/islands/favorite_button/favorite_button_view_model
import ../../models/dto/favorite_button/favorite_button_query_interface
import ../../models/vo/article_id
import ../../models/vo/user_id
import ../../di_container


type FavoriteButtonPresenter* = object
  query: IFavoriteButtonQuery

proc new*(_:type FavoriteButtonPresenter):FavoriteButtonPresenter =
  return FavoriteButtonPresenter(
    query: di.favoriteButtonQuery
  )


proc invoke*(self:FavoriteButtonPresenter, articleId:string, loginUserId:string):Future[FavoriteButtonViewModel] {.async.} =
  let articleId = ArticleId.new(articleId)
  let loginUserId = UserId.new(loginUserId)
  let favoriteButtonDto = self.query.invoke(articleId, loginUserId).await
  let viewModel = FavoriteButtonViewModel.new(favoriteButtonDto)
  return viewModel
