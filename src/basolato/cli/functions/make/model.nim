import os, strformat, terminal, strutils
import utils

# When aggregate is created,
# aggregate, repository, repository interface(in aggregate),
# usecase directory, query, query interface(in usecase)
# are created at the same time

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

proc new*(_:type {targetCaptalized}):{targetCaptalized} =
  return {targetCaptalized}()
"""

  let REPOSITORY_INTERFACE = &"""
import asyncdispatch
import {parent}_value_objects
import {targetName}_entity


type I{targetCaptalized}Repository* = tuple
"""

  let REPOSITORY = &"""
import asyncdispatch
import interface_implements
import allographer/query_builder
from ../../../../config/database import rdb
import ../../../models/{targetName}/{targetName}_value_objects
import ../../../models/{targetName}/{targetName}_entity
import ../../../models/{targetName}/{targetName}_repository_interface


type {targetCaptalized}Repository* = ref object

proc new*(_:type {targetCaptalized}Repository):{targetCaptalized}Repository =
  return {targetCaptalized}Repository()

implements {targetCaptalized}Repository, I{targetCaptalized}Repository:
  discard
"""

  let SERVICE = &"""
import {relativeToValueObjectsPath}
import {relativeToRepoInterface}
import {targetName}_entity


type {targetCaptalized}Service* = ref object
  repository: I{targetCaptalized}Repository

proc new*(_:type {targetCaptalized}Service, repository:I{parentCapitalized}Repository):{targetCaptalized}Service =
  return {targetCaptalized}Service(
    repository: repository
  )
"""

  let QUERY_INTERFACE = &"""
import asyncdispatch


type I{targetCaptalized}Query* = tuple
"""

  let QUERY = &"""
import interface_implements
import allographer/query_builder
from ../../../../config/database import rdb
import ../../../usecases/{target}/{target}_query_interface


type {targetCaptalized}Query* = ref object

proc new*(typ:type {targetCaptalized}Query):{targetCaptalized}Query =
  return {targetCaptalized}Query()

implements {targetCaptalized}Query, I{targetCaptalized}Query:
  discard
"""

  # check dir and file is not exists
  if isDirExists(&"{getCurrentDir()}/app/models/{target}"): return 1
  if not target.contains("/") and
      isDirExists(&"{getCurrentDir()}/app/data_stores/repositories/{targetName}"):
    return 1

  # create model dir
  var targetPath = &"{getCurrentDir()}/app/models/{target}"
  createDir(targetPath)

  # entity
  targetPath = &"{getCurrentDir()}/app/models/{target}/{targetName}_entity.nim"
  if isFileExists(targetPath): return 1
  var f = open(targetPath, fmWrite)
  defer: f.close()
  f.write(ENTITY)

  # service
  targetPath = &"{getCurrentDir()}/app/models/{target}/{targetName}_service.nim"
  if isFileExists(targetPath): return 1
  f = open(targetPath, fmWrite)
  f.write(SERVICE)

  # value objects
  targetPath = &"{getCurrentDir()}/app/models/{target}/{targetName}_value_objects.nim"
  if isFileExists(targetPath): return 1
  f = open(targetPath, fmWrite)
  f.write("")

  if not target.contains("/"):
    # repository interface
    targetPath = &"{getCurrentDir()}/app/models/{target}/{targetName}_repository_interface.nim"
    if isFileExists(targetPath): return 1
    f = open(targetPath, fmWrite)
    f.write(REPOSITORY_INTERFACE)

    # create repository dir
    targetPath = &"{getCurrentDir()}/app/data_stores/repositories/{target}"
    if isDirExists(targetPath): return 1
    createDir(targetPath)

    # repository
    targetPath = &"{getCurrentDir()}/app/data_stores/repositories/{target}/{targetName}_repository.nim"
    if isFileExists(targetPath): return 1
    f = open(targetPath, fmWrite)
    f.write(REPOSITORY)

    # create usecase dir
    targetPath = &"{getCurrentDir()}/app/usecases/{targetName}"
    createDir(targetPath)

    # create query dir
    targetPath = &"{getCurrentDir()}/app/data_stores/queries/{target}"
    if isDirExists(targetPath): return 1
    createDir(targetPath)

    # query
    targetPath = &"{getCurrentDir()}/app/data_stores/queries/{target}/{targetName}_query.nim"
    if isFileExists(targetPath): return 1
    f = open(targetPath, fmWrite)
    f.write(QUERY)

    # query interface
    targetPath = &"{getCurrentDir()}/app/usecases/{targetName}/{targetName}_query_interface.nim"
    if isFileExists(targetPath): return 1
    f = open(targetPath, fmWrite)
    f.write(QUERY_INTERFACE)

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
    textArr.insert(&"import data_stores/queries/{target}/{targetName}_query", importOffset-1)
    textArr.insert(&"import usecases/{targetName}/{targetName}_query_interface", importOffset-1)
    textArr.insert(&"import data_stores/repositories/{target}/{targetName}_repository", importOffset-1)
    textArr.insert(&"import models/{targetName}/{targetName}_repository_interface", importOffset-1)
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
    # field defintion
    textArr.insert(&"  {targetProcCaptalized}Repository: I{targetCaptalized}Repository", importDifinisionOffset)
    textArr.insert(&"  {targetProcCaptalized}Query: I{targetCaptalized}Query", importDifinisionOffset + 1)
    # insert constructor
    textArr.insert(&"    {targetProcCaptalized}Repository: {targetCaptalized}Repository.new().toInterface(),", textArr.len-4)
    textArr.insert(&"    {targetProcCaptalized}Query: {targetCaptalized}Query.new().toInterface(),", textArr.len-4)
    # write in file
    f = open(targetPath, fmWrite)
    for i in 0..textArr.len-2:
      f.writeLine(textArr[i])
    message = &"Updated {targetPath}"
    styledWriteLine(stdout, fgGreen, bgDefault, message, resetStyle)

    message = &"Created repository in {getCurrentDir()}/app/data_stores/repositories/{target}/{targetName}_repository.nim"
    styledWriteLine(stdout, fgGreen, bgDefault, message, resetStyle)

    message = &"Created query in {getCurrentDir()}/app/data_stores/queries/{target}/{targetName}_query.nim"
    styledWriteLine(stdout, fgGreen, bgDefault, message, resetStyle)

    message = &"Created usecase in {getCurrentDir()}/app/usecases/{target}"
    styledWriteLine(stdout, fgGreen, bgDefault, message, resetStyle)

  message = &"Created domain model in {getCurrentDir()}/app/models/{target}"
  styledWriteLine(stdout, fgGreen, bgDefault, message, resetStyle)

  return 0
