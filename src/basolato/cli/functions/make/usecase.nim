import os, strformat, terminal, strutils
import utils


proc makeUsecase*(dir, target:string, message:var string):int =
  let targetName = target.split("/")[^1]
  let targetCaptalized = snakeToCamel(target)
  let targetProcCaptalized = snakeToCamelProcName(targetName)
  var dirCaptalized = snakeToCamel(dir)
  let relativeToDiContainer = "../".repeat(dir.split("/").len-1) & "../../di_container"

  let USECASE = &"""
import {relativeToDiContainer}
import {dir}_query_interface


type {targetCaptalized}Usecase* = object
  query: I{dirCaptalized}Query

proc new*(_:type {targetCaptalized}Usecase):{targetCaptalized}Usecase =
  return {targetCaptalized}Usecase(
    query: di.{dir}Query
  )

proc run*(self:{targetCaptalized}Usecase) =
  discard
"""

  let QUERY_INTERFACE = &"""
import std/asyncdispatch


type I{dirCaptalized}Query* = tuple
"""

  let QUERY = &"""
import interface_implements
import allographer/query_builder
from ../../../config/database import rdb
import ../../usecases/{dir}/{dir}_query_interface


type {dirCaptalized}Query* = object

proc new*(_:type {dirCaptalized}Query):{dirCaptalized}Query =
  return {dirCaptalized}Query()

implements {dirCaptalized}Query, I{dirCaptalized}Query:
  discard
"""

  var targetPath:string
  var isExistsUsecaseDir: bool
  # create usecase dir
  targetPath = &"{getCurrentDir()}/app/usecases/{dir}"
  isExistsUsecaseDir = dirExists(targetPath)
  createDir(targetPath)

  # usecase
  targetPath = &"{getCurrentDir()}/app/usecases/{dir}/{targetName}_usecase.nim"
  if isFileExists(targetPath): return 1
  var f = open(targetPath, fmWrite)
  f.write(USECASE)

  if not isExistsUsecaseDir:
    # query interface
    targetPath = &"{getCurrentDir()}/app/usecases/{dir}/{dir}_query_interface.nim"
    if isFileExists(targetPath): return 1
    f = open(targetPath, fmWrite)
    f.write(QUERY_INTERFACE)

    # query
    targetPath = &"{getCurrentDir()}/app/data_stores/queries/{dir}_query.nim"
    if isFileExists(targetPath): return 1
    f = open(targetPath, fmWrite)
    f.write(QUERY)

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
    textArr.insert(&"import data_stores/queries/{dir}_query", importOffset-1)
    textArr.insert(&"import usecases/{dir}/{dir}_query_interface", importOffset-1)
    textArr.insert(&"# {dir}", importOffset-1)
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
    textArr.insert(&"  {dir}Query: I{dirCaptalized}Query", importDifinisionOffset)
    # insert constructor
    textArr.insert(&"    {dir}Query: {dirCaptalized}Query.new().toInterface(),", textArr.len-4)
    # write in file
    f = open(targetPath, fmWrite)
    for i in 0..textArr.len-2:
      f.writeLine(textArr[i])

    # update di container
    message = &"Updated {targetPath}"
    styledWriteLine(stdout, fgGreen, bgDefault, message, resetStyle)

    # create query
    message = &"Created query in {getCurrentDir()}/app/data_stores/queries/{dir}_query.nim"
    styledWriteLine(stdout, fgGreen, bgDefault, message, resetStyle)

  # create usecase
  message = &"Created usecase in {getCurrentDir()}/app/usecases/{dir}/{targetName}_usecase.nim"
  styledWriteLine(stdout, fgGreen, bgDefault, message, resetStyle)
  
  

  return 0
