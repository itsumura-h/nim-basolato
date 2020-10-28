import os, strformat, terminal, strutils
import utils


proc makeUsecase*(target:string, message:var string):int =
  var targetPath = &"{getCurrentDir()}/app/domain/usecases/{target}_usecase.nim"
  let targetName = target.split("/")[^1]
  let targetCaptalized = snakeToCamel(targetName)
  let reativeToValueObjectPath = "../".repeat(target.split("/").len) & "models/value_objects"
  let USECASE = &"""
import {reativeToValueObjectPath}
type {targetCaptalized}Usecase* = ref object
proc new{targetCaptalized}Usecase*():{targetCaptalized}Usecase =
  return {targetCaptalized}Usecase()
"""

  if isFileExists(targetPath): return 1
  createDir(parentDir(targetPath))

  var f = open(targetPath, fmWrite)
  defer: f.close()
  f.write(USECASE)

  message = &"created usecase in {targetPath}"
  styledWriteLine(stdout, fgGreen, bgDefault, message, resetStyle)
  return 0
