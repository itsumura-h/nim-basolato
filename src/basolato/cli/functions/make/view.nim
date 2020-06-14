import os, strformat, terminal, strutils
import utils

proc makeView*(target:string, message:var string):int =
  let targetPath = &"{getCurrentDir()}/resources/{target}View.nim"
  let targetName = target.split("/")[^1]
  let targetCaptalized = capitalizeAscii(targetName)
  let reativeToApplicationPath = "../".repeat(target.split("/").len-1) & "layouts/application"

  var VIEW = &"""
import basolato/view
import {reativeToApplicationPath}

proc impl():string = tmpli html'''
'''

proc {targetName}View*(this:View):string =
  let title = ''
  return this.applicationView(title, impl())
"""

  VIEW = VIEW.replace("'", "\"")

  if isFileExists(targetPath): return 1

  createDir(parentDir(targetPath))

  var f = open(targetPath, fmWrite)
  f.write(VIEW)
  defer: f.close()

  message = &"created view {target}View.nim"
  styledWriteLine(stdout, fgGreen, bgDefault, message, resetStyle)
  return 0
