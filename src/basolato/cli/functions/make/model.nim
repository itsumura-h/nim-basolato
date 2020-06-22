import os, strformat, terminal, strutils
import utils

proc makeModel*(target:string, message:var string):int =
  let targetName = target.split("/").max()
  let targetCaptalized = targetName.snake_to_camel()
  let ENTITY = &"""
import ../value_objects

type {targetCaptalized}* = ref object

proc new{targetCaptalized}*():{targetCaptalized} =
  return {targetCaptalized}()
"""

  let REPOSITORY_INTERFACE = &"""
import repositories/{targetName}_rdb_repository
export {targetName}_rdb_repository

# import repositories/{targetName}_json_repository
# export {targetName}_json_repository

type I{targetCaptalized}Repository* = ref object of RootObj
  repository*:{targetCaptalized}Repository

proc newI{targetCaptalized}Repository*():{targetCaptalized}Repository =
  return new{targetCaptalized}Repository()
"""

  let REPOSITORY = &"""
import ../../../../active_records/rdb
import ../{targetName}_entity
import ../../value_objects

type {targetCaptalized}Repository* = ref object

proc new{targetCaptalized}Repository*():{targetCaptalized}Repository =
  return {targetCaptalized}Repository()
"""

  let SERVICE = &"""
import {targetName}_entity
import {targetName}_repository_interface

type {targetCaptalized}Service* = ref object
  repository:{targetCaptalized}Repository

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

  message = &"created domain model in {getCurrentDir()}/app/domain/models/{targetName}"
  styledWriteLine(stdout, fgGreen, bgDefault, message, resetStyle)
  return 0
