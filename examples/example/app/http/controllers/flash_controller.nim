import std/asyncdispatch
import std/json
# framework
import ../../../../../src/basolato/controller
import ../views/presenters/app_presenter
import ../views/layouts/app/app_layout
import ../views/pages/flash/flash_page


proc index*(context:Context):Future[Response] {.async.} =
  const title = "Flash message"
  let appPresenter = AppPresenter.new()
  let appLayoutModel = appPresenter.invoke(title)
  let page = flashPage().await
  let view = appLayout(appLayoutModel, page)
  return render(view)


proc store*(context:Context):Future[Response] {.async.} =
  await context.setFlash("msg", "This is flash message")
  return redirect("/sample/flash")
