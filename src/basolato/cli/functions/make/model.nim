import os, strformat, terminal, strutils
import utils

proc makeModel*(target:string, message:var string):int =
  let targetName = target.split("/")[^1]
  let targetCaptalized = snakeToCamel(targetName)
  let targetProcCaptalized = snakeToCamelProcName(targetName)
  let parent = target.split("/")[0]
  let parentCapitalized = snakeToCamel(parent)
  let relativeToValueObjectsPath = "../".repeat(target.split("/").len-1) & &"{parent}_value_objects"
  let relativeToRepoInterface = "../".repeat(target.split("/").len-1) & parent & "_repository_interface"

  let ENTITY = &"""
import {relativeToValueObjectsPath}


type {targetCaptalized}* = ref object

proc new{targetCaptalized}*():{targetCaptalized} =
  result = new {targetCaptalized}
"""

  let REPOSITORY_INTERFACE = &"""
import asyncdispatch
import {parent}_value_objects
import {targetName}_entity


type I{targetCaptalized}Repository* = tuple
"""

  let REPOSITORY = &"""
import interface_implements
import allographer/query_builder
from ../../../database import rdb
import ../../core/models/{targetName}/{targetName}_value_objects
import ../../core/models/{targetName}/{targetName}_entity
import ../../core/models/{targetName}/{targetName}_repository_interface


type {targetCaptalized}Repository* = ref object

proc new{targetCaptalized}Repository*():{targetCaptalized}Repository =
  result = new {targetCaptalized}Repository

implements {targetCaptalized}Repository, I{targetCaptalized}Repository:
  discard
"""

  let QUERY_SERVICE_INTERFACE = &"""
import asyncdispatch


type I{targetCaptalized}QueryService* = tuple
"""

  let QUERY_SERVICE = &"""
import interface_implements
import allographer/query_builder
from ../../../database import rdb
import ../../core/models/{targetName}/{targetName}_query_service_interface


type {targetCaptalized}QueryService* = ref object

proc new{targetCaptalized}QueryService*():{targetCaptalized}QueryService =
  result = new {targetCaptalized}QueryService

implements {targetCaptalized}QueryService, I{targetCaptalized}QueryService:
  discard
"""

  let SERVICE = &"""
import {relativeToValueObjectsPath}
import {targetName}_entity
import {relativeToRepoInterface}


type {targetCaptalized}Service* = ref object
  repository: I{targetCaptalized}Repository

proc new{targetCaptalized}Service*(repository:I{parentCapitalized}Repository):{targetCaptalized}Service =
  result = new {targetCaptalized}Service
  result.repository = repository
"""

  # check dir and file is not exists
  if isDirExists(&"{getCurrentDir()}/app/core/models/{target}"): return 1
  if isDirExists(&"{getCurrentDir()}/app/repositories/{targetName}"): return 1

  # create model dir
  var targetPath = &"{getCurrentDir()}/app/core/models/{target}"
  createDir(targetPath)

  # entity
  targetPath = &"{getCurrentDir()}/app/core/models/{target}/{targetName}_entity.nim"
  if isFileExists(targetPath): return 1
  var f = open(targetPath, fmWrite)
  defer: f.close()
  f.write(ENTITY)

  # service
  targetPath = &"{getCurrentDir()}/app/core/models/{target}/{targetName}_service.nim"
  if isFileExists(targetPath): return 1
  f = open(targetPath, fmWrite)
  f.write(SERVICE)

  if not target.contains("/"):
    # value objects
    targetPath = &"{getCurrentDir()}/app/core/models/{target}/{target}_value_objects.nim"
    if isFileExists(targetPath): return 1
    f = open(targetPath, fmWrite)
    f.write("")

    # repository interface
    targetPath = &"{getCurrentDir()}/app/core/models/{targetName}/{targetName}_repository_interface.nim"
    if isFileExists(targetPath): return 1
    f = open(targetPath, fmWrite)
    f.write(REPOSITORY_INTERFACE)

    # query service interface
    targetPath = &"{getCurrentDir()}/app/core/models/{targetName}/{targetName}_query_service_interface.nim"
    if isFileExists(targetPath): return 1
    f = open(targetPath, fmWrite)
    f.write(QUERY_SERVICE_INTERFACE)

    # create repository dir
    targetPath = &"{getCurrentDir()}/app/repositories/{targetName}"
    if isDirExists(targetPath): return 1
    createDir(targetPath)

    # repository
    targetPath = &"{getCurrentDir()}/app/repositories/{targetName}/{targetName}_repository.nim"
    if isFileExists(targetPath): return 1
    f = open(targetPath, fmWrite)
    f.write(REPOSITORY)

    # query service
    targetPath = &"{getCurrentDir()}/app/repositories/{targetName}/{targetName}_query_service.nim"
    if isFileExists(targetPath): return 1
    f = open(targetPath, fmWrite)
    f.write(QUERY_SERVICE)

    # update di_container.nim
    targetPath = &"{getCurrentDir()}/app/di_container.nim"
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
    textArr.insert(&"import repositories/{targetName}/{targetName}_repository", importOffset-1)
    textArr.insert(&"import core/models/{targetName}/{targetName}_repository_interface", importOffset-1)
    textArr.insert(&"import repositories/{targetName}/{targetName}_query_service", importOffset-1)
    textArr.insert(&"import core/models/{targetName}/{targetName}_query_service_interface", importOffset-1)
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
    textArr.insert(&"  {targetProcCaptalized}Repository: I{targetCaptalized}Repository", importDifinisionOffset)
    textArr.insert(&"  {targetProcCaptalized}QueryService: I{targetCaptalized}QueryService", importDifinisionOffset)
    # insert constructor
    textArr.insert(&"    {targetProcCaptalized}Repository: new{targetCaptalized}Repository().toInterface(),", textArr.len-4)
    textArr.insert(&"    {targetProcCaptalized}QueryService: new{targetCaptalized}QueryService().toInterface(),", textArr.len-4)
    # write in file
    f = open(targetPath, fmWrite)
    for i in 0..textArr.len-2:
      f.writeLine(textArr[i])
    message = &"Updated {targetPath}"
    styledWriteLine(stdout, fgGreen, bgDefault, message, resetStyle)

  message = &"Created domain model in {getCurrentDir()}/app/core/models/{target}"
  styledWriteLine(stdout, fgGreen, bgDefault, message, resetStyle)

  message = &"Created repository in {getCurrentDir()}/app/repositories/{target}"
  styledWriteLine(stdout, fgGreen, bgDefault, message, resetStyle)

  return 0
