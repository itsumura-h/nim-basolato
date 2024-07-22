import std/asyncdispatch
import std/os
import std/tables
# framework
import ../../../../../src/basolato/controller
# view
import ../views/presenters/app_presenter
import ../views/layouts/app/app_layout
import ../views/pages/file_upload/file_upload_page


proc index*(context:Context):Future[Response] {.async.} =
  let page = fileUploadPage()

  const title = "File upload view"
  let appPresenter = AppPresenter.new()
  let appLayoutModel = appPresenter.invoke(title)
  let view = appLayout(appLayoutModel, page)
  return render(view)


proc store*(context:Context):Future[Response] {.async.} =
  if context.params.hasKey("img"):
    context.params.save("img", "./public/sample")
    context.params.save("img", "./public/sample", "image")
  return redirect("/sample/file-upload")


proc destroy*(context:Context):Future[Response] {.async.} =
  removeDir(getCurrentDir() / "public/sample", true)
  return redirect("/sample/file-upload")
