import os, strformat, terminal, strutils
import utils

proc makeAggregate*(target:string, message:var string):int =
  let targetName = target.split("/").max()
  let targetCaptalized = snakeToCamel(targetName)
  let ENTITY = &"""
import ../value_objects


type {targetCaptalized}* = ref object

proc new{targetCaptalized}*():{targetCaptalized} =
  return {targetCaptalized}()
"""

  let REPOSITORY_INTERFACE = &"""
import ../value_objects
import {targetName}_entity
include ../di_container


type I{targetCaptalized}Repository* = ref object


proc newI{targetCaptalized}Repository*():I{targetCaptalized}Repository =
  return newI{targetCaptalized}Repository()
"""

  let REPOSITORY = &"""
import allographer/query_builder
import ../../model/aggregate/value_objects


type {targetCaptalized}RdbRepository* = ref object


proc new{targetCaptalized}Repository*():{targetCaptalized}RdbRepository =
  return {targetCaptalized}RdbRepository()

proc sampleProc*(this:{targetCaptalized}RdbRepository) =
  echo "{targetCaptalized}RdbRepository sampleProc"
"""

  let SERVICE = &"""
import ../value_objects
import {targetName}_entity
import {targetName}_repository_interface


type {targetCaptalized}Service* = ref object
  repository:I{targetCaptalized}Repository


proc new{targetCaptalized}Service*():{targetCaptalized}Service =
  return {targetCaptalized}Service(
    repository:newI{targetCaptalized}Repository()
  )
"""

  # create domain dir
  var targetPath = &"{getCurrentDir()}/app/model/aggregates/{targetName}"
  if isDirExists(targetPath): return 1
  createDir(targetPath)

  # entity
  targetPath = &"{getCurrentDir()}/app/model/aggregates/{targetName}/{targetName}_entity.nim"
  if isFileExists(targetPath): return 1
  var f = open(targetPath, fmWrite)
  defer: f.close()
  f.write(ENTITY)

  # repository interface
  targetPath = &"{getCurrentDir()}/app/model/aggregates/{targetName}/{targetName}_repository_interface.nim"
  if isFileExists(targetPath): return 1
  f = open(targetPath, fmWrite)
  f.write(REPOSITORY_INTERFACE)

  # repository
  targetPath = &"{getCurrentDir()}/app/repositories/{targetName}/{targetName}_rdb_repository.nim"
  if isFileExists(targetPath): return 1
  f = open(targetPath, fmWrite)
  f.write(REPOSITORY)

  # service
  targetPath = &"{getCurrentDir()}/app/model/aggregates/{targetName}/{targetName}_service.nim"
  if isFileExists(targetPath): return 1
  f = open(targetPath, fmWrite)
  f.write(SERVICE)

  # update di_container.nim
  targetPath = &"{getCurrentDir()}/app/model/aggregate/di_container.nim"
  f = open(targetPath, fmRead)
  var textArr = f.readAll().splitLines()
  # get offset where column is empty string
  var importOffset:int
  for i, row in textArr:
    if row == "type DiContainer* = tuple":
      importOffset = i
      break
  if importOffset < 1:
    textArr.insert("", 0)
    importOffset = 1
  # insert array
  textArr.insert(&"import ../../repositories/{targetName}/{targetName}_rdb_repository", importOffset-1)
  textArr.insert(&"  {targetName}Repository: {targetCaptalized}RdbRepository", textArr.len-1)
  # write in file
  f = open(targetPath, fmWrite)
  for i in 0..textArr.len-2:
    f.writeLine(textArr[i])
  message = &"Updated di_container.nim"
  styledWriteLine(stdout, fgGreen, bgDefault, message, resetStyle)

  message = &"Created domain model in {getCurrentDir()}/app/model/aggregates/{targetName}"
  styledWriteLine(stdout, fgGreen, bgDefault, message, resetStyle)
  return 0
