import os, strformat, terminal, strutils
import utils

proc makeView*(target:string, message:var string):int =
  let targetPath = &"{getCurrentDir()}/resources/{target}_view.nim"
  let targetName = target.split("/")[^1]
  let targetCaptalized = snakeToCamelProcName(targetName)
  let reativeToApplicationPath = "../".repeat(target.split("/").len-1) & "layouts/application_view"

  var VIEW = &"""
import basolato/view
import {reativeToApplicationPath}

proc impl():string = tmpli html'''
'''

proc {targetCaptalized}View*():string =
  let title = ''
  return applicationView(title, impl())
"""

  VIEW = VIEW.replace("'", "\"")

  if isFileExists(targetPath): return 1
  createDir(parentDir(targetPath))

  var f = open(targetPath, fmWrite)
  f.write(VIEW)
  defer: f.close()

  message = &"created view {targetPath}"
  styledWriteLine(stdout, fgGreen, bgDefault, message, resetStyle)
  return 0
