import std/asyncdispatch
import std/options
import std/strutils
import std/sequtils
import basolato/controller
import basolato/request_validation
import ../views/pages/editor/editor_page
import ../../di_container
import ../../usecases/create_article_usecase
import ../../usecases/update_article_usecase
import ../../models/vo/article_id
import ../../models/aggregates/article/article_repository_interface
import ../../errors

proc createPage*(context: Context): Future[Response] {.async.} =
  let page = await editorPageView(context, "/editor")
  return render(page)

proc updatePage*(context: Context): Future[Response] {.async.} =
  let articleId = context.params.getStr("articleId")
  let articleOpt = await di.articleRepository.getArticleById(ArticleId.new(articleId))
  if articleOpt.isNone():
    raise newException(IdNotFoundError, "article not found")

  let article = articleOpt.get()
  let loginUserId = context.get("user_id").await
  if article.userId.value != loginUserId:
    raise newException(DomainError, "forbidden")
  let tags = article.tags.mapIt(it.name.value).join(", ")
  let page = await editorPageView(
    context,
    "/editor/" & articleId,
    article.title.value,
    article.description.value,
    article.body.value,
    tags,
  )
  return render(page)

proc create*(context: Context): Future[Response] {.async.} =
  let validation = RequestValidation.new(context)
  validation.required("title", "Title")
  validation.required("description", "Description")
  validation.required("body", "Body")
  if validation.hasErrors():
    context.storeValidationResult(validation).await
    return redirect("/editor")

  let title = context.params.getStr("title")
  let description = context.params.getStr("description")
  let body = context.params.getStr("body")
  let tags = context.params.getStr("tags").split(",").mapIt(it.strip()).filterIt(it.len > 0)
  let userId = context.get("user_id").await
  let articleId = await CreateArticleUsecase.new().invoke(userId, title, description, body, tags)
  return redirect("/article/" & articleId)

proc update*(context: Context): Future[Response] {.async.} =
  let articleId = context.params.getStr("articleId")
  let validation = RequestValidation.new(context)
  validation.required("title", "Title")
  validation.required("description", "Description")
  validation.required("body", "Body")
  if validation.hasErrors():
    context.storeValidationResult(validation).await
    return redirect("/editor/" & articleId)

  let title = context.params.getStr("title")
  let description = context.params.getStr("description")
  let body = context.params.getStr("body")
  let tags = context.params.getStr("tags").split(",").mapIt(it.strip()).filterIt(it.len > 0)
  let userId = context.get("user_id").await
  await UpdateArticleUsecase.new().invoke(userId, articleId, title, description, body, tags)
  return redirect("/article/" & articleId)
