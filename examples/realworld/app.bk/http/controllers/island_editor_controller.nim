import std/httpcore
import std/tables
import std/strutils
import std/strformat
import std/json
import basolato/controller
import basolato/request_validation
import basolato/core/logger
import ../../errors
import ../views/pages/editor/editor_view_model
import ../views/pages/editor/editor_view
import ../views/components/form_error_message/form_error_message_view_model
import ../views/components/form_error_message/form_error_message_view
import ../../usecases/create_article_usecase
import ../../usecases/get_article_in_editor/get_article_in_editor_usecase
import ../../usecases/update_article_usecase


proc create*(context:Context, params:Params):Future[Response] {.async.} =
  let viewModel = EditorViewModel.new()
  let view = islandEditorView(viewModel)
  return render(view)


proc store*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  v.required("title")
  v.required("body")
  if v.hasErrors:
    var errors:seq[string]

    for (key, msg) in v.errors.pairs():
      errors.add(msg)
    
    let viewModel = FormErrorMessageViewModel.new(errors)
    let view = formErrorMessageView(viewModel)
    let header = {
      "HX-Reswap": "innerHTML show:top",
      "HX-Retarget": "#form-message",
    }.newHttpHeaders()
    return render(view, header)
  
  let authorId = context.get("id").await
  let title = params.getStr("title")
  let description = params.getStr("description")
  let body = params.getStr("body")
  let tagsJson = params.getStr("tags").parseJson()
  var tags:seq[string]
  for tag in tagsJson.items:
    tags.add(tag["value"].getStr)

  try:
    let usecase = CreateArticleUsecase.new()
    let articleId = usecase.invoke(authorId, title, description, body, tags).await
    let headers = {
      "HX-Redirect": &"/articles/{articleId}",
    }.newHttpHeaders()
    return redirect("", headers)
  except IdNotFoundError, DomainError:
    let error = getCurrentExceptionMsg()
    echoErrorMsg(error)
    let viewModel = FormErrorMessageViewModel.new(@[error])
    let view = formErrorMessageView(viewModel)
    let header = {
      "HX-Reswap": "innerHTML show:top",
      "HX-Retarget": "#form-message",
    }.newHttpHeaders()
    return render(view, header)
  except:
    let error = getCurrentExceptionMsg()
    echoErrorMsg(error)
    let viewModel = FormErrorMessageViewModel.new(@["error"])
    let view = formErrorMessageView(viewModel)
    let header = {
      "HX-Reswap": "innerHTML show:top",
      "HX-Retarget": "#form-message",
    }.newHttpHeaders()
    return render(view, header)


proc update*(context:Context, params:Params):Future[Response] {.async.} =
  try:
    let articleId = params.getStr("articleId")
    let usecase = GetArticleInEditorUsecase.new()
    let article = usecase.invoke(articleId).await
    let viewModel = EditorViewModel.new(article)
    let view = islandEditorView(viewModel)
    return render(view)
  except IdNotFoundError:
    let error = getCurrentExceptionMsg()
    echoErrorMsg(error)
    return render(Http404, error)
  except DomainError:
    let error = getCurrentExceptionMsg()
    echoErrorMsg(error)
    return render(Http400, error)
  except:
    let error = getCurrentExceptionMsg()
    echoErrorMsg(error)
    return render(Http500, "error")


proc edit*(context:Context, params:Params):Future[Response] {.async.} =
  let v = RequestValidation.new(params)
  v.required("title")
  v.required("body")
  if v.hasErrors:
    var errors:seq[string]

    for (key, msg) in v.errors.pairs():
      errors.add(msg)
    
    let viewModel = FormErrorMessageViewModel.new(errors)
    let view = formErrorMessageView(viewModel)
    let header = {
      "HX-Reswap": "innerHTML show:top",
      "HX-Retarget": "#form-message",
    }.newHttpHeaders()
    return render(view, header)
  
  echo params.getAll().pretty()
  let authorId = context.get("id").await
  let articleId = params.getStr("articleId")
  let title = params.getStr("title")
  let description = params.getStr("description")
  let body = params.getStr("body")
  let tagsJson = params.getStr("tags").parseJson()
  var tags:seq[string]
  for tag in tagsJson.items:
    tags.add(tag["value"].getStr)

  try:
    let usecase = UpdateArticleUsecase.new()
    usecase.invoke(authorId, articleId, title, description, body, tags).await
    let headers = {
      "HX-Redirect": &"/articles/{articleId}",
    }.newHttpHeaders()
    return redirect("", headers)
  except IdNotFoundError, DomainError:
    let error = getCurrentExceptionMsg()
    echoErrorMsg(error)
    let viewModel = FormErrorMessageViewModel.new(@[error])
    let view = formErrorMessageView(viewModel)
    let header = {
      "HX-Reswap": "innerHTML show:top",
      "HX-Retarget": "#form-message",
    }.newHttpHeaders()
    return render(view, header)
  except:
    let error = getCurrentExceptionMsg()
    echoErrorMsg(error)
    let viewModel = FormErrorMessageViewModel.new(@["error"])
    let view = formErrorMessageView(viewModel)
    let header = {
      "HX-Reswap": "innerHTML show:top",
      "HX-Retarget": "#form-message",
    }.newHttpHeaders()
    return render(view, header)
