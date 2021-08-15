import os, strformat, terminal, strutils
import utils


proc makeUsecase*(target:string, message:var string):int =
  var targetPath = &"{getCurrentDir()}/app/core/usecases/{target}_usecase.nim"
  let targetName = target.split("/")[^1]
  let targetCaptalized = snakeToCamel(targetName)
  let USECASE = &"""
import ../../di_container


type {targetCaptalized}Usecase* = ref object

proc new{targetCaptalized}Usecase*():{targetCaptalized}Usecase =
  result = new {targetCaptalized}Usecase
"""

  if isFileExists(targetPath): return 1
  createDir(parentDir(targetPath))

  var f = open(targetPath, fmWrite)
  defer: f.close()
  f.write(USECASE)

  message = &"Created usecase in {targetPath}"
  styledWriteLine(stdout, fgGreen, bgDefault, message, resetStyle)
  return 0
