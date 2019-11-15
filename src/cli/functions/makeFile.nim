import os, strformat, strutils, terminal

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

proc isFileExists(targetPath:string):bool =
  if existsFile(targetPath):
    let message = &"{targetPath} is already exists"
    styledWriteLine(stdout, fgRed, bgDefault, message, resetStyle)
    return true
  else:
    return false

proc createParentDir(target:string, dir:string) =
  if target.contains("/"):
    var targetDirArray = target.split("/")
    targetDirArray.delete(targetDirArray.len - 1)
    let targetDir = getCurrentDir() & dir & targetDirArray.join("/")
    createDir(targetDir)

proc make*(args:seq[string]):int =
  ## make file
  var
    message:string
    todo:string
    target:string

  try:
    todo = args[0]
    target = args[1]
  except:
    message = "Missing args"
    styledWriteLine(stdout, fgRed, bgDefault, message, resetStyle)
    return 0

  # check whether you are in dir includes main.nim
  let mainPath = getCurrentDir() & "/main.nim"
  if existsFile(mainPath) == false:
    message = "Wrong directory. You should be in the dir which includes main.nim"
    styledWriteLine(stdout, fgRed, bgDefault, message, resetStyle)
    return 0

  case todo:
  of "controller":
    let targetPath = getCurrentDir() & "/app/controllers/" & target & "Controller.nim"

    if isFileExists(targetPath): return 0

    createParentDir(target, "/app/controllers/")

    var f = open(targetPath, fmWrite)
    f.write(CONTROLLER)
    defer: f.close()

    message = &"create controller {target}Controller"
    styledWriteLine(stdout, fgGreen, bgDefault, message, resetStyle)
  else:
    message = "invalid things to make"
    styledWriteLine(stdout, fgRed, bgDefault, message, resetStyle)
  