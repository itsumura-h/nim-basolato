import std/os
import std/strformat
import std/strutils
import std/terminal
import ./utils


proc makeController*(target:string, message:var string):int =
  let targetPath = &"{getCurrentDir()}/app/http/controllers/{target}_controller.nim"
  # let targetName = target.split("/")[^1]
  let controller = &"""
import std/json
# framework
import basolato/controller


proc index*(context:Context, params:Params):Future[Response] ASYNC =
  return render("index")

proc show*(context:Context, params:Params):Future[Response] ASYNC =
  let id = params.getInt("id")
  return render("show")

proc create*(context:Context, params:Params):Future[Response] ASYNC =
  return render("create")

proc store*(context:Context, params:Params):Future[Response] ASYNC =
  return render("store")

proc edit*(context:Context, params:Params):Future[Response] ASYNC =
  let id = params.getInt("id")
  return render("edit")

proc update*(context:Context, params:Params):Future[Response] ASYNC =
  let id = params.getInt("id")
  return render("update")

proc destroy*(context:Context, params:Params):Future[Response] ASYNC =
  let id = params.getInt("id")
  return render("destroy")
"""
  let CONTROLLER = controller.replace("ASYNC", "{.async.}")

  if isFileExists(targetPath): return 1

  createDir(parentDir(targetPath))

  var f = open(targetPath, fmWrite)
  defer: f.close()
  f.write(CONTROLLER)

  message = &"Created controller in {targetPath}"
  styledWriteLine(stdout, fgGreen, bgDefault, message, resetStyle)
  return 0
