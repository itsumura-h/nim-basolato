import std/asyncdispatch
import ../../http/views/pages/article/favorite_button/favorite_button_in_article_view_model
import ../../models/dto/favorite_button/favorite_button_query_interface
import ../../models/vo/article_id
import ../../models/vo/user_id
import ../../di_container


type FavoriteButtonInArticlesPresenter* = object
  query: IFavoriteButtonQuery

proc new*(_:type FavoriteButtonInArticlesPresenter):FavoriteButtonInArticlesPresenter =
  return FavoriteButtonInArticlesPresenter(
    query: di.favoriteButtonQuery
  )


proc invoke*(self:FavoriteButtonInArticlesPresenter, articleId:string, loginUserId:string):Future[FavoriteButtonInArticleViewModel] {.async.} =
  let articleId = ArticleId.new(articleId)
  let loginUserId = UserId.new(loginUserId)
  let favoriteButtonDto = self.query.invoke(articleId, loginUserId).await
  let viewModel = FavoriteButtonInArticleViewModel.new(favoriteButtonDto)
  return viewModel
