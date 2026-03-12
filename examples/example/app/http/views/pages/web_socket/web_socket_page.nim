import std/asyncdispatch
import ../../../../../../../src/basolato/view
import ../../presenters/app_presenter
import ../../layouts/app/app_layout
import ../../templates/web_socket/web_socket_iframe_template
import ../../templates/web_socket/web_socket_template


proc webSocketIframePageView*(context: Context):Future[Component] {.async.} =
  const title = "Web Socket Iframe Page"
  let appPresenter = AppPresenter.new()
  let appLayoutModel = appPresenter.invoke(title)
  return appLayout(appLayoutModel, webSocketIframeTemplate())


proc webSocketPageView*(context: Context):Future[Component] {.async.} =
  const title = "Web Socket Page"
  let appPresenter = AppPresenter.new()
  let appLayoutModel = appPresenter.invoke(title)
  return appLayout(appLayoutModel, webSocketTemplate())
