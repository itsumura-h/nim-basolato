import std/asyncdispatch
import ../../../../../../../src/basolato/view
import ../../layouts/app/app_layout
import ../../presenters/app_presenter
import ../../templates/api_view/api_view_template


proc apiViewPageView*(context: Context):Future[Component] {.async.} =
  const title = "API View"
  let appPresenter = AppPresenter.new()
  let appLayoutModel = appPresenter.invoke(title)

  let apiViewBody = apiViewTemplate()
  return appLayout(appLayoutModel, apiViewBody)
