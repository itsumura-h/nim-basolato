import basolato/controller
import basolato/core/logger
import ../../errors
import ../../usecases/get_article_in_editor/get_article_in_editor_usecase
import ./libs/create_app_view_model
import ../views/pages/editor/editor_view_model
import ../views/pages/editor/editor_view


proc create*(context:Context, params:Params):Future[Response] {.async.} =
  let appViewModel = createAppViewModel(context, "Editor ―Conduit").await
  let viewModel = EditorViewModel.new()
  let view = editorView(appViewModel, viewModel)
  return render(view)


proc update*(context:Context, params:Params):Future[Response] {.async.} =
  let appViewModel = createAppViewModel(context, "Editor ―Conduit").await
  let articleId = params.getStr("articleId")
  try:
    let usecase = GetArticleInEditorUsecase.new()
    let article = usecase.invoke(articleId).await
    let viewModel = EditorViewModel.new(article)
    let view = editorView(appViewModel, viewModel)
    return render(view)
  except IdNotFoundError:
    let error = getCurrentExceptionMsg()
    echoErrorMsg(error)
    return render(Http404, "Not Found")
  except DomainError:
    let error = getCurrentExceptionMsg()
    echoErrorMsg(error) 
    return render(Http400, "Bad Request")
  except:
    let error = getCurrentExceptionMsg()
    echoErrorMsg(error)
    return render(Http500, "Internal Server Error")
