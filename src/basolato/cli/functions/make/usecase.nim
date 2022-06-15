import os, strformat, terminal, strutils
import utils


proc makeUsecase*(dir, target:string, message:var string):int =
  let targetName = target.split("/")[^1]
  let targetCaptalized = snakeToCamel(target)
  let targetProcCaptalized = snakeToCamelProcName(targetName)
  var dirCaptalized = snakeToCamel(dir)
  let relativeToDiContainer = "../".repeat(dir.split("/").len-1) & "../../../di_container"

  let USECASE = &"""
import {relativeToDiContainer}
import {targetName}_query_interface


type {targetCaptalized}Usecase* = ref object
  query: I{targetCaptalized}Query

proc new*(_:type {targetCaptalized}Usecase):{targetCaptalized}Usecase =
  return {targetCaptalized}Usecase(
    query: di.{targetProcCaptalized}Query
  )

proc run*(self:{targetCaptalized}Usecase) =
  discard
"""

  let QUERY_INTERFACE = &"""
import asyncdispatch


type I{targetCaptalized}Query* = tuple
"""

  let QUERY = &"""
import interface_implements
import allographer/query_builder
from ../../../../config/database import rdb
import ../../../usecases/{dir}/{target}/{target}_query_interface


type {targetCaptalized}Query* = ref object

proc new*(_:type {targetCaptalized}Query):{targetCaptalized}Query =
  return {targetCaptalized}Query()

implements {targetCaptalized}Query, I{targetCaptalized}Query:
  discard
"""

  var targetPath:string
  # create usecase dir
  targetPath = &"{getCurrentDir()}/app/usecases/{dir}/{target}"
  createDir(targetPath)

  # create query dir
  targetPath = &"{getCurrentDir()}/app/data_stores/queries/{dir}"
  createDir(targetPath)

  # usecase
  targetPath = &"{getCurrentDir()}/app/usecases/{dir}/{target}/{targetName}_usecase.nim"
  if isFileExists(targetPath): return 1
  var f = open(targetPath, fmWrite)
  f.write(USECASE)

  # query
  targetPath = &"{getCurrentDir()}/app/data_stores/queries/{dir}/{targetName}_query.nim"
  if isFileExists(targetPath): return 1
  f = open(targetPath, fmWrite)
  f.write(QUERY)

  # query interface
  targetPath = &"{getCurrentDir()}/app/usecases/{dir}/{target}/{targetName}_query_interface.nim"
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
  textArr.insert(&"import data_stores/queries/{dir}/{targetName}_query", importOffset-1)
  textArr.insert(&"import usecases/{dir}/{target}/{targetName}_query_interface", importOffset-1)
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
  textArr.insert(&"  {targetProcCaptalized}Query: I{targetCaptalized}Query", importDifinisionOffset)
  # insert constructor
  textArr.insert(&"    {targetProcCaptalized}Query: {targetCaptalized}Query.new().toInterface(),", textArr.len-4)
  # write in file
  f = open(targetPath, fmWrite)
  for i in 0..textArr.len-2:
    f.writeLine(textArr[i])
  message = &"Updated {targetPath}"
  styledWriteLine(stdout, fgGreen, bgDefault, message, resetStyle)

  message = &"Created usecase in {getCurrentDir()}/app/usecases/{dir}/{target}/{targetName}_usecase.nim"
  styledWriteLine(stdout, fgGreen, bgDefault, message, resetStyle)
  
  message = &"Created query in {getCurrentDir()}/app/data_stores/queries/{dir}/{targetName}_query.nim"
  styledWriteLine(stdout, fgGreen, bgDefault, message, resetStyle)

  return 0
