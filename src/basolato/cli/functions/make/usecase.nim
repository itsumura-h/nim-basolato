import os, strformat, terminal, strutils
import utils


proc makeUsecase*(target:string, message:var string):int =
  let targetName = target.split("/")[^1]
  let targetCaptalized = snakeToCamel(targetName)
  let relativeToDiContainer = "../".repeat(target.split("/").len-1) & "../../di_container"

  let USECASE = &"""
import {relativeToDiContainer}


type {targetCaptalized}Usecase* = ref object

proc new*(typ:type {targetCaptalized}Usecase):{targetCaptalized}Usecase =
  typ()
"""

  var targetPath = &"{getCurrentDir()}/app/usecases/{target}_usecase.nim"
  # check dir and file is not exists
  if isDirExists(targetPath):
    return 1

  if isFileExists(targetPath): return 1
  createDir(parentDir(targetPath))
  var f = open(targetPath, fmWrite)
  defer: f.close()
  f.write(USECASE)
  message = &"Created usecase in {targetPath}"
  styledWriteLine(stdout, fgGreen, bgDefault, message, resetStyle)

  return 0
