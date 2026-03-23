import std/asyncdispatch
import ../../../../../../../src/basolato/view
import ../../layouts/app/app_layout
import ../../presenters/app_presenter
import ../../presenters/validation/validation_page_viewmodel
import ../../templates/validation/validation_template


proc validationPageView*(context: Context):Future[Component] {.async.} =
  const title = "Validation view"
  let appPresenter = AppPresenter.new()
  let appLayoutModel = appPresenter.invoke(title)

  let (params, errors) = context.getParamsWithErrorsObject().await
  let csrfToken = context.getCsrfToken()
  let vm = ValidationPageViewModel.new(params, errors, csrfToken)

  let page = validationTemplate(vm)
  return appLayout(appLayoutModel, page)
