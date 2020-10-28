import os, strformat, terminal, strutils
import utils

proc makeModel*(target:string, message:var string):int =
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
include ../di_container


type I{targetCaptalized}Repository* = ref object


proc newI{targetCaptalized}Repository*():I{targetCaptalized}Repository =
  return newI{targetCaptalized}Repository()
"""

  let REPOSITORY = &"""
import allographer/query_builder
import ../{targetName}_entity
import ../../value_objects


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
  var targetPath = &"{getCurrentDir()}/app/domain/models/{targetName}"
  if isDirExists(targetPath): return 1
  createDir(targetPath)

  # create repository dir
  targetPath = &"{getCurrentDir()}/app/domain/models/{targetName}/repositories"
  if isDirExists(targetPath): return 1
  createDir(targetPath)

  # entity
  targetPath = &"{getCurrentDir()}/app/domain/models/{targetName}/{targetName}_entity.nim"
  if isFileExists(targetPath): return 1
  var f = open(targetPath, fmWrite)
  defer: f.close()
  f.write(ENTITY)

  # repository interface
  targetPath = &"{getCurrentDir()}/app/domain/models/{targetName}/{targetName}_repository_interface.nim"
  if isFileExists(targetPath): return 1
  f = open(targetPath, fmWrite)
  f.write(REPOSITORY_INTERFACE)

  # repository
  targetPath = &"{getCurrentDir()}/app/domain/models/{targetName}/repositories/{targetName}_rdb_repository.nim"
  if isFileExists(targetPath): return 1
  f = open(targetPath, fmWrite)
  f.write(REPOSITORY)

  # service
  targetPath = &"{getCurrentDir()}/app/domain/models/{targetName}/{targetName}_service.nim"
  if isFileExists(targetPath): return 1
  f = open(targetPath, fmWrite)
  f.write(SERVICE)

    # update di_container.nim
  targetPath = &"{getCurrentDir()}/app/domain/models/di_container.nim"
  f = open(targetPath, fmRead)
  let text = f.readAll()
  var textArr = text.splitLines()
  # get offset where column is empty string
  var offsets:seq[int]
  for i, row in textArr:
    if row == "":
      offsets.add(i)
  # insert array
  textArr.insert(&"import {targetName}/repositories/{targetName}_rdb_repository", offsets[0])
  textArr.insert(&"  {targetName}Repository: {targetCaptalized}RdbRepository", offsets[1]+1)
  # write in file
  f = open(targetPath, fmWrite)
  for i in 0..textArr.len-2:
    f.writeLine(textArr[i])
  message = &"updated di_container.nim"
  styledWriteLine(stdout, fgGreen, bgDefault, message, resetStyle)

  message = &"created domain model in {getCurrentDir()}/app/domain/models/{targetName}"
  styledWriteLine(stdout, fgGreen, bgDefault, message, resetStyle)
  return 0
