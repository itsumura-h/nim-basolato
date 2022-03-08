import os
# framework
import ../../../../../src/basolato/controller
# view
import ../views/pages/sample/file_upload_view

proc index*(context:Context, params:Params):Future[Response] {.async.} =
  return render(await fileUploadView())

proc store*(context:Context, params:Params):Future[Response] {.async.} =
  if params.hasKey("img"):
    params.save("img", "./public/sample")
    params.save("img", "./public/sample", "image")
  return redirect("/sample/file-upload")

proc destroy*(context:Context, params:Params):Future[Response] {.async.} =
  removeDir(getCurrentDir() / "public/sample", true)
  return redirect("/sample/file-upload")