import std/options
import std/strformat
# framework
import basolato/controller
import ../../errors
import ../views/pages/user/user_show_view_model
import ../views/pages/user/user_show_view
import ../../presenters/app/app_presenter
import ../../presenters/user_show/user_show_presenter


proc show*(context:Context, params:Params):Future[Response] {.async.} =
  let loginUserId =
    if context.isLogin().await:
      context.get("id").await.some()
    else:
      none(string)
  let userId = params.getStr("userId")
  let page =
    if params.hasKey("page"):
      params.getInt("page")
    else:
      1
  try:
    let userShowPresenter = UserShowPresenter.new()
    let userShowViewModel = userShowPresenter.invoke(userId, loginUserId, page).await    

    let appPresenter = AppPresenter.new()
    let title = &"{userShowViewModel.user.name} ― Cnduit"
    let appViewModel = appPresenter.invoke(loginUserId, title).await

    let view = userShowView(appViewModel, userShowViewModel)
    return render(view)
  except IdNotFoundError:
    return render(Http404, "")


# proc favorites*(context:Context, params:Params):Future[Response] {.async.} =
#   let isLogin = context.isLogin().await
#   let userId = params.getStr("userId")
#   let loginUserId = context.get("id").await
#   let loginUserIdOpt = if loginUserId.len > 0: loginUserId.some() else: none(string)
#   let isSelf = isLogin and loginUserId == userId
#   let loadFavorites = true
#   try:
#     let favoritesInUserPresenter = FavoritesInUserPresenter.new()
#     let favoritesInUserViewModel = favoritesInUserPresenter.invoke(userId, loginUserIdOpt).await   

#     let getFollowButtonUsecase = GetFollowButtonInUserUsecase.new()
#     let followButtonDto = getFollowButtonUsecase.invoke(userId, loginUserId).await

#     let title = &"Articles favorited by {dto.id} ― Cnduit"
#     let appViewModel = createAppViewModel(context, title).await
#     let viewModel = UserShowViewModel.new(dto, followButtonDto, isSelf, loadFavorites)
#     let view = userShowView(appViewModel, viewModel)
#     return render(view)
#   except IdNotFoundError:
#     return render(Http404, "")
