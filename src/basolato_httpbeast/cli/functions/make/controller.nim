import os, strformat, terminal, strutils
import utils

proc makeController*(target:string, message:var string):int =
  let targetPath = &"{getCurrentDir()}/app/controllers/{target}_controller.nim"
  let targetName = target.split("/").max()
  let controller = &"""
import json
# framework
import basolato/controller

proc index*(request:Request, params:Params):Future[Response] ASYNC =
  return render("index")

proc show*(request:Request, params:Params):Future[Response] ASYNC =
  let id = params.urlParams["id"].getInt
  return render("show")

proc create*(request:Request, params:Params):Future[Response] ASYNC =
  return render("create")

proc store*(request:Request, params:Params):Future[Response] ASYNC =
  return render("store")

proc edit*(request:Request, params:Params):Future[Response] ASYNC =
  let id = params.urlParams["id"].getInt
  return render("edit")

proc update*(request:Request, params:Params):Future[Response] ASYNC =
  let id = params.urlParams["id"].getInt
  return render("update")

proc destroy*(request:Request, params:Params):Future[Response] ASYNC =
  let id = params.urlParams["id"].getInt
  return render("destroy")
"""
  let CONTROLLER = controller.replace("ASYNC", "{.async.}")

  if isFileExists(targetPath): return 1

  createDir(parentDir(targetPath))

  var f = open(targetPath, fmWrite)
  defer: f.close()
  f.write(CONTROLLER)

  message = &"created controller {target}_controller.nim"
  styledWriteLine(stdout, fgGreen, bgDefault, message, resetStyle)
  return 0