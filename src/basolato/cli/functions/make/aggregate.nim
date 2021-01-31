import os, strformat, terminal, strutils
import utils

proc makeAggregate*(target:string, message:var string):int =
  let targetName = target
  let targetCaptalized = snakeToCamel(targetName)
  let ENTITY = &"""
import ../../value_objects


type {targetCaptalized}* = ref object

proc new{targetCaptalized}*():{targetCaptalized} =
  return {targetCaptalized}()
"""

  let REPOSITORY_INTERFACE = &"""
import ../../value_objects
import {targetName}_entity


type I{targetCaptalized}Repository* = tuple
"""

  let REPOSITORY = &"""
import allographer/query_builder
import ../../model/value_objects
import ../../model/aggregates/{targetName}/{targetName}_repository_interface


type {targetCaptalized}RdbRepository* = ref object

proc new{targetCaptalized}Repository*():{targetCaptalized}RdbRepository =
  return {targetCaptalized}RdbRepository()


proc toInterface*(this:{targetCaptalized}RdbRepository):I{targetCaptalized}Repository =
  return ()
"""

  let SERVICE = &"""
import ../../value_objects
import {targetName}_entity
import {targetName}_repository_interface


type {targetCaptalized}Service* = ref object
  repository: I{targetCaptalized}Repository

proc new{targetCaptalized}Service*(repository:I{targetCaptalized}Repository):{targetCaptalized}Service =
  return {targetCaptalized}Service(
    repository: repository
  )
"""

  if isTargetContainSlash(target, "aggregate"): return 0

  # create aggregate dir
  var targetPath = &"{getCurrentDir()}/app/model/aggregates/{targetName}"
  if isDirExists(targetPath): return 1
  createDir(targetPath)

  # create repository dir
  targetPath = &"{getCurrentDir()}/app/repositories/{targetName}"
  if isDirExists(targetPath): return 1
  createDir(targetPath)

  # repository
  targetPath = &"{getCurrentDir()}/app/repositories/{targetName}/{targetName}_rdb_repository.nim"
  if isFileExists(targetPath): return 1
  var f = open(targetPath, fmWrite)
  defer: f.close()
  f.write(REPOSITORY)

  # entity
  targetPath = &"{getCurrentDir()}/app/model/aggregates/{targetName}/{targetName}_entity.nim"
  if isFileExists(targetPath): return 1
  f = open(targetPath, fmWrite)
  f.write(ENTITY)

  # repository interface
  targetPath = &"{getCurrentDir()}/app/model/aggregates/{targetName}/{targetName}_repository_interface.nim"
  if isFileExists(targetPath): return 1
  f = open(targetPath, fmWrite)
  f.write(REPOSITORY_INTERFACE)

  # service
  targetPath = &"{getCurrentDir()}/app/model/aggregates/{targetName}/{targetName}_service.nim"
  if isFileExists(targetPath): return 1
  f = open(targetPath, fmWrite)
  f.write(SERVICE)

  # update di_container.nim
  targetPath = &"{getCurrentDir()}/app/model/di_container.nim"
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
  # insert import
  textArr.insert(&"import ../repositories/{targetName}/{targetName}_rdb_repository", importOffset-1)
  textArr.insert(&"import aggregates/{targetName}/{targetName}_repository_interface", importOffset-1)
  textArr.insert(&"# {targetName}", importOffset-1)
  # insert di difinition
  var isAfterDiDifinision:bool
  var importDifinisionOffset:int
  for i, row in textArr:
    if row == "type DiContainer* = tuple":
      isAfterDiDifinision = true
    if isAfterDiDifinision and row == "":
      importDifinisionOffset = i
      break
  textArr.insert(&"  {targetName}Repository: I{targetCaptalized}Repository", importDifinisionOffset)
  # insert constructor
  textArr.insert(&"    {targetName}Repository: new{targetCaptalized}Repository().toInterface(),", textArr.len-4)
  # write in file
  f = open(targetPath, fmWrite)
  for i in 0..textArr.len-2:
    f.writeLine(textArr[i])
  message = &"Updated di_container.nim"
  styledWriteLine(stdout, fgGreen, bgDefault, message, resetStyle)

  message = &"Created domain aggregate in {getCurrentDir()}/app/model/aggregates/{targetName}"
  styledWriteLine(stdout, fgGreen, bgDefault, message, resetStyle)
  return 0
