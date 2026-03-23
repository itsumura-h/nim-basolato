import std/asyncdispatch
import std/options
# framework
import basolato/controller
import basolato/view
import ../../errors
import ../../presenters/app/app_presenter
import ../../presenters/article/article_presenter
import ../views/pages/article/article_view_model
import ../views/pages/article/article_view


proc show*(context:Context, params:Params):Future[Response] {.async.} =
  let loginUserId =
    if context.isLogin().await:
      context.get("id").await.some()
    else:
      none(string)
  let articleId = params.getStr("articleId")

  try:
    let articlePresenter = ArticlePresenter.new()
    let articleViewModel = articlePresenter.invoke(articleId, loginUserId).await
    let appPresenter = AppPresenter.new()
    let appViewModel = appPresenter.invoke(loginUserId, articleViewModel.article.title).await
    let view = articleShowPageView(appViewModel, articleViewModel)
    return render(view)
  except IdNotFoundError:
    return render(Http404, "")
  except:
    return render(Http400, getCurrentExceptionMsg())


proc islandShow*(context:Context, params:Params):Future[Response] {.async.} =
  let loginUserId =
    if context.isLogin().await:
      context.get("id").await.some()
    else:
      none(string)
  let articleId = params.getStr("articleId")

  try:
    let articlePresenter = ArticlePresenter.new()
    let articleViewModel = articlePresenter.invoke(articleId, loginUserId).await
    let view = articleShowPageView(, articleViewModel)
    return render(view)
  except IdNotFoundError:
    return render(Http404, "")
  except:
    return render(Http400, getCurrentExceptionMsg())
