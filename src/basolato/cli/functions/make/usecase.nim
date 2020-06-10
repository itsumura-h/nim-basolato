import os, strformat, terminal, strutils
import utils

proc makeUsecase*(target:string, message:var string):int =
  let targetName = target.split("/").max()
  let targetCaptalized = capitalizeAscii(targetName)
  let USECASE = &"""
type {targetCaptalized}Usecase* = ref object

proc new{targetCaptalized}Usecase*():{targetCaptalized}Usecase =
  return {targetCaptalized}Usecase()
"""

  var targetPath = &"{getCurrentDir()}/app/domain/usecases/{targetName}_usecase.nim"
  if isFileExists(targetPath): return 1
  var f = open(targetPath, fmWrite)
  defer: f.close()
  f.write(USECASE)

  message = &"created usecase in {targetPath}"
  styledWriteLine(stdout, fgGreen, bgDefault, message, resetStyle)
  return 0
