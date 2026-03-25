import std/asyncdispatch
# framework
import basolato/controller
import basolato/request_validation
import ../views/pages/article/article_page
import ../views/templates/article/article_template_model
import ../views/templates/article/article_turbo_stream
import ../views/components/article_action/article_action_component_model
import ../views/components/feed_article/feed_article_component
import ../../usecases/favorite_usecase
import ../../usecases/follow_usecase
import ../../usecases/create_comment_usecase
import ../../usecases/delete_comment_usecase
import ../../usecases/delete_article_usecase


proc articlePage*(context:Context):Future[Response] {.async.} =
  let page = articlePageView(context).await
  return render(page)


proc favorite*(context:Context):Future[Response] {.async.} =
  let articleId = context.params.getStr("articleId")
  let loginUserId = context.get("user_id").await
  await FavoriteUsecase.new().invoke(articleId, loginUserId)
  let model = ArticleTemplateModel.new(context).await
  let actionModel = ArticleActionComponentModel.new(
    articleId = model.articleId,
    authorId = model.author.id,
    authorName = model.author.name,
    authorImage = model.author.image,
    followerCount = model.author.followerCount,
    isFollowed = model.author.isFollowed,
    favoriteCount = model.article.favoriteCount,
    isFavorited = model.article.isFavorited,
    csrfToken = model.csrfToken,
    isAuthor = model.isAuthor
  )
  let turboStream = articleTurboStream(actionModel)
  return renderTurboStream(turboStream)


proc favoriteCompact*(context:Context):Future[Response] {.async.} =
  let articleId = context.params.getStr("articleId")
  let loginUserId = context.get("user_id").await
  await FavoriteUsecase.new().invoke(articleId, loginUserId)
  let model = ArticleTemplateModel.new(context).await
  let turboStream = feedArticleFavoriteTurboStream(
    model.articleId,
    model.article.favoriteCount,
    model.article.isFavorited,
    model.csrfToken
  )
  return renderTurboStream(turboStream)


proc followFromArticle*(context:Context):Future[Response] {.async.} =
  let userId = context.params.getStr("userId")
  let loginUserId = context.get("user_id").await
  await FollowUsecase.new().invoke(loginUserId, userId)
  let model = ArticleTemplateModel.new(context).await
  let actionModel = ArticleActionComponentModel.new(
    articleId = model.articleId,
    authorId = model.author.id,
    authorName = model.author.name,
    authorImage = model.author.image,
    followerCount = model.author.followerCount,
    isFollowed = model.author.isFollowed,
    favoriteCount = model.article.favoriteCount,
    isFavorited = model.article.isFavorited,
    csrfToken = model.csrfToken,
    isAuthor = model.isAuthor
  )
  let turboStream = articleTurboStream(actionModel)
  return renderTurboStream(turboStream)


proc createComment*(context:Context):Future[Response] {.async.} =
  let validation = RequestValidation.new(context)
  validation.required("body", "Comment")
  if validation.hasErrors():
    context.storeValidationResult(validation).await
    return redirect("/article/" & context.params.getStr("articleId"))

  let articleId = context.params.getStr("articleId")
  let loginUserId = context.get("user_id").await
  let body = context.params.getStr("body")
  await CreateCommentUsecase.new().invoke(articleId, loginUserId, body)
  return redirect("/article/" & articleId)


proc deleteComment*(context:Context):Future[Response] {.async.} =
  let articleId = context.params.getStr("articleId")
  let commentId = context.params.getStr("commentId")
  let loginUserId = context.get("user_id").await
  await DeleteCommentUsecase.new().invoke(loginUserId, commentId)
  return redirect("/article/" & articleId)


proc delete*(context:Context):Future[Response] {.async.} =
  let articleId = context.params.getStr("articleId")
  let loginUserId = context.get("user_id").await
  await DeleteArticleUsecase.new().invoke(loginUserId, articleId)
  return redirect("/")
