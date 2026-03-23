import std/asyncdispatch
# framework
import ../../../../../../../src/basolato/view
import ../../layouts/app/app_layout
import ../../presenters/app_presenter
import ../../presenters/cookie/cookie_page_presenter
import ../../presenters/cookie/cookie_page_viewmodel
import ../../templates/cookie/cookie_template


proc cookiePageView*(context: Context):Future[Component] {.async.} =
  const title = "Cookie"
  let appPresenter = AppPresenter.new()
  let appLayoutModel = appPresenter.invoke(title)

  let presenter = CookiePagePresenter.new()
  let vm = presenter.invoke(context).await
  let page = cookieTemplate(vm)
  return appLayout(appLayoutModel, page)
