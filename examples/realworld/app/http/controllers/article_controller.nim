import std/asyncdispatch
# framework
import basolato/controller
import basolato/request_validation
import ../views/pages/article/article_page
import ../../usecases/favorite_usecase
import ../../usecases/create_comment_usecase
import ../../usecases/delete_comment_usecase
import ../../usecases/delete_article_usecase


proc show*(context:Context):Future[Response] {.async.} =
  let page = articlePageView(context).await
  return render(page)


proc favorite*(context:Context):Future[Response] {.async.} =
  let articleId = context.params.getStr("articleId")
  let loginUserId = context.get("user_id").await
  await FavoriteUsecase.new().invoke(articleId, loginUserId)
  return redirect("/article/" & articleId)


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
