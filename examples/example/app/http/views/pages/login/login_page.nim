import std/asyncdispatch
import ../../../../../../../src/basolato/view
import ../../layouts/app/app_layout
import ../../presenters/app_presenter
import ../../presenters/login/login_presenter
import ../../templates/login/login_template


proc loginPageView*(context: Context):Future[Component] {.async.} =
  const title = "Login Page"
  let appPresenter = AppPresenter.new()
  let appLayoutModel = appPresenter.invoke(title)

  let presenter = LoginPresenter.new()
  let vm = presenter.invoke(context).await
  let page = loginTemplate(vm)
  return appLayout(appLayoutModel, page)
