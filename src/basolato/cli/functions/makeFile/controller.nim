const CONTROLLER = """
from strutils import parseInt

import basolato/controller

proc index*(): Response =
  return render("index")

proc show*(idArg: string): Response =
  let id = idArg.parseInt
  return render("show")

proc create*(): Response =
  return render("create")

proc store*(request: Request): Response =
  return render("store")

proc edit*(idArg: string): Response =
  let id = idArg.parseInt
  return render("edit")

proc update*(request: Request): Response =
  return render("update")

proc destroy*(idArg: string): Response =
  let id = idArg.parseInt
  return render("destroy")
"""

import os, strformat, strutils, terminal
import utils

proc makeController*(target:string, message:var string):int =
  let targetPath = &"{getCurrentDir()}/app/controllers/{target}Controller.nim"

  if isFileExists(targetPath): return 0

  createDir(parentDir(targetPath))

  var f = open(targetPath, fmWrite)
  f.write(CONTROLLER)
  defer: f.close()

  message = &"create controller {target}Controller"
  styledWriteLine(stdout, fgGreen, bgDefault, message, resetStyle)
  return 1