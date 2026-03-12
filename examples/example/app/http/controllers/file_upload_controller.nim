import std/asyncdispatch
import std/os
import std/tables
# framework
import ../../../../../src/basolato/controller
# view
import ../views/pages/file_upload/file_upload_page


proc fileUploadPage*(context:Context):Future[Response] {.async.} =
  let page = fileUploadPageView(context).await
  return render(page)


proc store*(context:Context):Future[Response] {.async.} =
  if context.params.hasKey("img"):
    context.params.save("img", "./public/sample")
    context.params.save("img", "./public/sample", "image")
  return redirect("/sample/file-upload")


proc destroy*(context:Context):Future[Response] {.async.} =
  removeDir(getCurrentDir() / "public/sample", true)
  return redirect("/sample/file-upload")
