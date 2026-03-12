import std/asyncdispatch
import ../../../../../../../src/basolato/view
import ../../layouts/app/app_layout
import ../../presenters/app_presenter
import ../../templates/with_style/with_style_template


proc withStylePageView*(context: Context):Future[Component] {.async.} =
  const title = "With Style"
  let appPresenter = AppPresenter.new()
  let appLayoutModel = appPresenter.invoke(title)
  let page = withStyleTemplate()
  return appLayout(appLayoutModel, page)
