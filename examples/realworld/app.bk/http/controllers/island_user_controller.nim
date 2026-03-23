import std/options
# framework
import basolato/controller
import ../../errors
# user show
import ../../presenters/user_show/user_show_presenter
import ../views/pages/user/user_show_view
# user feed
import ../../presenters/article_preview/user_article_list_presenter
import ../views/islands/article_preview/article_preview_view
# # favoriteArticles
# import ../../usecases/get_favorites_in_user/get_favorites_in_user_usecase
# follow
import ../../usecases/follow_usecase
import ../../presenters/follow_button_in_user/follow_button_in_user_presenter
import ../../http/views/islands/follow_button/follow_button_view
# favorite
import ../../usecases/favorite_usecase
import ../../presenters/favorite_button/favorite_button_presenter
import ../../http/views/islands/favorite_button/favorite_button_view


proc show*(context:Context, params:Params):Future[Response] {.async.} =
  let isLogin = context.isLogin().await
  let userId = params.getStr("userId")
  let loginUserId = context.get("id").await
  let loginUserIdOpt = if isLogin: loginUserId.some() else: none(string)
  let page =
    if params.hasKey("page"):
      params.getInt("page")
    else:
      1
  try:
    let userShowPresenter = UserShowPresenter.new()
    let userShowViewModel = userShowPresenter.invoke(userId, loginUserIdOpt, page).await
    let view = islandUserShowView(userShowViewModel)
    return render(view)
  except IdNotFoundError:
    return render(Http404, "")


proc articles*(context:Context, params:Params):Future[Response] {.async.} =
  let page =
    if params.hasKey("page"):
      params.getInt("page")
    else:
      1
  let userId = params.getStr("userId")
  let isLogin = context.isLogin().await
  let loginUserId = context.get("id").await
  
  try:
    let presenter = UserArticleListPresenter.new()
    let viewModel = presenter.invoke(page, userId, isLogin, loginUserId).await
    let view = articlePreviewView(viewModel)
    return render(view)
  except IdNotFoundError:
    return render(Http404, "")


# proc favoriteArticles*(context:Context, params:Params):Future[Response] {.async.} =
#   let userId = params.getStr("userId")
#   let loginUserId = context.get("id").await
#   try:
#     let usecase = GetFavoritesInUserUsecase.new()
#     let dto = usecase.invoke(userId, loginUserId).await
#     let viewModel = HtmxUserFeedViewModel.new(dto)
#     let view = htmxUserFeedView(viewModel)
#     return render(view)
#   except IdNotFoundError:
#     return render(Http404, "")


proc follow*(context:Context, params:Params):Future[Response] {.async.} =
  let userId = params.getStr("userId")
  let loginUserId = context.get("id").await
  try:
    let followUsecase = FollowUsecase.new()
    followUsecase.invoke(userId, loginUserId).await

    let followButtonPresenter = FollowButtonInUserPresenter.new()
    let viewModel = followButtonPresenter.invoke(userId, loginUserId).await
    let view = followButtonView(viewModel)
    return render(view)
  except:
    return render(Http400, getCurrentExceptionMsg())


proc favorite*(context:Context, params:Params):Future[Response] {.async.} =
  let articleId = params.getStr("articleId")
  # let isLogin = context.isLogin().await
  let loginUserId = context.get("id").await
  try:
    let followUsecase = FavoriteUsecase.new()
    followUsecase.invoke(articleId, loginUserId).await

    let presenter = FavoriteButtonPresenter.new()
    let viewModel = presenter.invoke(articleId, loginUserId).await
    let view = favoriteButtonView(viewModel)
    return render(view)
  except:
    return render(Http400, getCurrentExceptionMsg())
