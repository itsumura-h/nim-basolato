import std/asyncdispatch
import std/options
# framework
import basolato/controller
import basolato/view
import ../../presenters/app/app_presenter
import ../../presenters/home/global_feed_presenter
import ../../presenters/home/tag_feed_presenter
import ../../presenters/home/your_feed_presenter
import ../views/pages/home/home_view


proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let loginUserId =
    if context.isLogin().await:
      context.get("id").await.some()
    else:
      none(string)

  let appPresenter = AppPresenter.new()
  let appViewModel = appPresenter.invoke(loginUserId, "conduit").await

  let globalFeedPresenter = GlobalFeedPresenter.new()
  let homeViewModel = globalFeedPresenter.invoke()
  let view = homeView(appViewModel, homeViewModel)
  return render(view)


proc yourFeed*(context:Context, params:Params):Future[Response] {.async.} =
  let page =
    if params.hasKey("page"):
      params.getInt("page")
    else:
      1
  let loginUserId =
    if context.isLogin().await:
      context.get("id").await.some()
    else:
      return render(Http403, "Forbidden")
  let hasPage = page > 1

  let appPresenter = AppPresenter.new()
  let appViewModel = appPresenter.invoke(loginUserId, "conduit").await

  let presenter = YourFeedPresenter.new()
  let viewModel = presenter.invoke(hasPage, page)
  let view = homeView(appViewModel, viewModel)
  return render(view)


proc tagFeed*(context:Context, params:Params):Future[Response] {.async.} =
  let loginUserId =
    if context.isLogin().await:
      context.get("id").await.some()
    else:
      none(string)

  let appPresenter = AppPresenter.new()
  let appViewModel = appPresenter.invoke(loginUserId, "conduit").await
  
  let page =
    if params.hasKey("page"):
      params.getInt("page")
    else:
      1
  let hasPage = page > 1
  let tagName = params.getStr("tag")

  let tagFeedPresenter = TagFeedPresenter.new()
  let homeViewModel = tagFeedPresenter.invoke(
    tagName,
    hasPage,
    page
  )
  let view = homeView(appViewModel, homeViewModel)
  return render(view)
