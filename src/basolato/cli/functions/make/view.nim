import os, strformat, terminal, strutils
import utils

proc makeView*(target:string, message:var string):int =
  let targetPath = &"{getCurrentDir()}/resources/{target}Html.nim"
  let targetName = target.split("/").max()
  let targetCaptalized = capitalizeAscii(targetName)

  var VIEW = &"""
import basolato/view

proc {targetName}Html*():string = tmpli html'''
'''
"""
  VIEW = VIEW.replace("'''", "\"\"\"")

  if isFileExists(targetPath): return 1

  createDir(parentDir(targetPath))

  var f = open(targetPath, fmWrite)
  f.write(VIEW)
  defer: f.close()

  message = &"created view {target}Html.nim"
  styledWriteLine(stdout, fgGreen, bgDefault, message, resetStyle)
  return 0
