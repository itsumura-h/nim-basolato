import std/asyncdispatch
import ../../../../../../../src/basolato/view
import ../../layouts/app/app_layout
import ../../presenters/app_presenter
import ../../templates/sample/sample_template


proc samplePageView*(context: Context):Future[Component] {.async.} =
  const title = "Sample index"
  let appPresenter = AppPresenter.new()
  let appLayoutModel = appPresenter.invoke(title)

  let page = sampleTemplate()
  return appLayout(appLayoutModel, page)
