import std/asyncdispatch
import std/options
import ../../http/views/pages/article/article_view_model
import ../../models/dto/article_detail/article_detail_query_interface
import ../../models/dto/follow_button/follow_button_query_interface
import ../../models/dto/favorite_button/favorite_button_query_interface
import ../../models/vo/article_id
import ../../models/vo/user_id
import ../../di_container


type ArticlePresenter* = object
  articleQuery:IArticleDetailQuery
  favoriteButtonQuery:IFavoriteButtonQuery
  followButtonQuery:IFollowButtonQuery

proc new*(_:type ArticlePresenter):ArticlePresenter =
  return ArticlePresenter(
    articleQuery: di.articleDetailQuery,
    favoriteButtonQuery: di.favoriteButtonQuery,
    followButtonQuery: di.followButtonQuery,
  )
  

proc invoke*(self:ArticlePresenter, articleId:string, loginUserId:Option[string]):Future[ArticleViewModel] {.async.} =
  let articleId = ArticleId.new(articleId)
  let loginUserId =
    if loginUserId.isSome():
      UserId.new(loginUserId.get()).some()
    else:
      none(UserId)
  
  let articleDto = self.articleQuery.invoke(articleId).await

  let favoriteButtonDto =
    if loginUserId.isSome():
      self.favoriteButtonQuery.invoke(articleId, loginUserId.get()).await
    else:
      self.favoriteButtonQuery.invoke(articleId).await

  let authorId = UserId.new(articleDto.author.id)
  let followButtonDto = self.followButtonQuery.invoke(authorId, loginUserId).await

  let articleViewModel = ArticleViewModel.new(articleDto, favoriteButtonDto, followButtonDto, loginUserId)
  return articleViewModel
