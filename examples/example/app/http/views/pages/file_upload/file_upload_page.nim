import std/asyncdispatch
import ../../../../../../../src/basolato/view
import ../../layouts/app/app_layout
import ../../presenters/app_presenter
import ../../presenters/file_upload/file_upload_page_viewmodel
import ../../templates/file_upload/file_upload_template


proc fileUploadPageView*(context: Context):Future[Component] {.async.} =
  const title = "File Upload"
  let appPresenter = AppPresenter.new()
  let appLayoutModel = appPresenter.invoke(title)

  let csrfToken = context.getCsrfToken()
  let vm = FileUploadPageViewModel.new(csrfToken)
  let page = fileUploadTemplate(vm)
  return appLayout(appLayoutModel, page)
