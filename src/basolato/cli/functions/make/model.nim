import os, strformat, terminal, strutils
import utils

proc makeModel*(target:string, message:var string):int =
  let targetName = target.split("/")[^1]
  let targetCaptalized = snakeToCamel(targetName)
  let relativeToValueObjectsPath = "../".repeat(target.split("/").len) & "value_objects"

  let ENTITY = &"""
import {relativeToValueObjectsPath}


type {targetCaptalized}* = ref object

proc new{targetCaptalized}*():{targetCaptalized} =
  return {targetCaptalized}()
"""

  let SERVICE = &"""
import {relativeToValueObjectsPath}
import {targetName}_entity


type {targetCaptalized}Service* = ref object


proc new{targetCaptalized}Service*():{targetCaptalized}Service =
  return {targetCaptalized}Service()
"""

  # create domain dir
  var targetPath = &"{getCurrentDir()}/app/model/aggregates/{target}"
  if isDirExists(targetPath): return 1
  createDir(targetPath)

  # entity
  targetPath = &"{getCurrentDir()}/app/model/aggregates/{target}/{targetName}_entity.nim"
  if isFileExists(targetPath): return 1
  var f = open(targetPath, fmWrite)
  defer: f.close()
  f.write(ENTITY)

  # service
  targetPath = &"{getCurrentDir()}/app/model/aggregates/{target}/{targetName}_service.nim"
  if isFileExists(targetPath): return 1
  f = open(targetPath, fmWrite)
  f.write(SERVICE)

  message = &"Created domain model in {getCurrentDir()}/app/model/aggregates/{targetName}"
  styledWriteLine(stdout, fgGreen, bgDefault, message, resetStyle)
  return 0
