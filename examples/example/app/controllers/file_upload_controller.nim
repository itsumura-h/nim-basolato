import os
# framework
import ../../../../src/basolato/controller
# view
import ../../resources/pages/sample/file_upload_view

proc index*(request:Request, params:Params):Future[Response] {.async.} =
  return render(fileUploadView())

proc store*(request:Request, params:Params):Future[Response] {.async.} =
  if params.hasKey("img"):
    params.save("img", "./public/sample")
    params.save("img", "./public/sample", "image")
  return redirect("/sample/file-upload")

proc destroy*(request:Request, params:Params):Future[Response] {.async.} =
  removeDir(getCurrentDir() / "public/sample", true)
  return redirect("/sample/file-upload")
