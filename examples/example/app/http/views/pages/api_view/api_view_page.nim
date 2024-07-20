import ../../../../../../../src/basolato/view
import ../../templates/api_view/api_view_template
import ../../presenters/app_presenter
import ../../layouts/app/app_layout


proc apiViewPage*():Component =
  const title = "API View"
  let appPresenter = AppPresenter.new()
  let appLayoutModel = appPresenter.invoke(title)

  let apiViewTemplate = apiViewTemplate()
  return appLayout(appLayoutModel, apiViewTemplate)
