import std/asyncdispatch
import std/options
# framework
import basolato/controller
import basolato/view
import ../../di_container
# article show
import ../../presenters/article/article_presenter
import ../views/pages/article/article_view
# comment
import ../../presenters/comment/comment_list_in_article_presenter
import ../views/pages/comment/comment_view
# import ../../usecases/get_comments_in_article/get_comments_in_article_usecase
# import ../views/pages/comment/comment_view_model
# import ../views/pages/comment/comment_view
# # delete
# import ../../usecases/delete_article_usecase
# favorite
import ../../usecases/favorite_usecase
import ../../presenters/favorite_button_in_articles/favorite_button_in_articles_presenter
import ../views/pages/article/favorite_button/favorite_button_in_article_view


proc show*(context:Context, params:Params):Future[Response] {.async.} =
  let articleId = params.getStr("articleId")
  let loginUserId =
    if context.isLogin().await:
      context.get("id").await.some()
    else:
      none(string)
  let presenter = ArticlePresenter.new()
  let viewModel = presenter.invoke(articleId, loginUserId).await
  let view = islandArticleShowView(viewModel)
  return render(view)


proc comments*(context:Context, params:Params):Future[Response] {.async.} =
  let articleId = params.getStr("articleId")
  let loginUserId =
    if context.isLogin().await:
      context.get("id").await.some()
    else:
      none(string)
  let presenter = CommentListInArticlePresenter.new()
  let viewModel = presenter.invoke(articleId, loginUserId).await
  let view = commentView(viewModel)
  return render(view)


# proc delete*(context:Context, params:Params):Future[Response] {.async.} =
#   let articleId = params.getStr("articleId")
#   let userId = context.get("id").await
#   let usecase = DeleteArticleUsecase.new()
#   usecase.invoke(articleId).await
#   let header = {
#     "HX-Redirect": &"/users/{userId}",
#   }.newHttpHeaders()
#   return render("", header)


proc favorite*(context:Context, params:Params):Future[Response] {.async.} =
  let articleId = params.getStr("articleId")
  # let isLogin = context.isLogin().await
  let loginUserId = context.get("id").await
  try:
    let followUsecase = FavoriteUsecase.new()
    followUsecase.invoke(articleId, loginUserId).await

    let presenter = FavoriteButtonInArticlesPresenter.new()
    let viewModel = presenter.invoke(articleId, loginUserId).await
    let view = favoriteButtonInArticleView(viewModel)
    return render(view)
  except:
    return render(Http400, getCurrentExceptionMsg())
