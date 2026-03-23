import std/asyncdispatch
import ../../../../../../../src/basolato/view
import ../../layouts/app/app_layout
import ../../presenters/app_presenter
import ../../presenters/flash/flash_page_viewmodel
import ../../templates/flash/flash_template


proc flashPageView*(context: Context):Future[Component] {.async.} =
  const title = "Flash message"
  let appPresenter = AppPresenter.new()
  let appLayoutModel = appPresenter.invoke(title)

  let flashMessageList = context.getFlash().await
  let csrfToken = context.getCsrfToken()
  let vm = FlashPageViewModel.new(flashMessageList, csrfToken)

  let page = flashTemplate(vm)
  return appLayout(appLayoutModel, page)
