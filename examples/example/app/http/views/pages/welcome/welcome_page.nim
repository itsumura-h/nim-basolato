import std/asyncdispatch
import ../../../../../../../src/basolato/view
import ../../layouts/app/app_layout
import ../../presenters/app_presenter
import ../../presenters/welcome/welcome_page_viewmodel
import ../../templates/welcome/welcome_template


proc welcomePageView*(context: Context):Future[Component] {.async.} =
  const title = "Welcome"
  let appPresenter = AppPresenter.new()
  let appLayoutModel = appPresenter.invoke(title)

  let vm = WelcomePageViewModel.new()
  let page = welcomeTemplate(vm)
  return appLayout(appLayoutModel, page)
