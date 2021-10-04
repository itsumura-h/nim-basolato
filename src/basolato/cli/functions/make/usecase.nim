import os, strformat, terminal, strutils
import utils


proc makeUsecase*(dir, target:string, message:var string):int =
  var targetCaptalized = snakeToCamel(target)
  var dirCaptalized = snakeToCamel(dir)
  let relativeToDiContainer = "../".repeat(dir.split("/").len-1) & "../../di_container"

  let USECASE = &"""
import {relativeToDiContainer}


type {targetCaptalized}Usecase* = ref object

proc new*(_:type {targetCaptalized}Usecase):{targetCaptalized}Usecase =
  return {targetCaptalized}Usecase()

proc run*(self:{targetCaptalized}Usecase) =
  discard
"""

  var targetPath = &"{getCurrentDir()}/app/usecases/{dir}/{target}_usecase.nim"
  # check dir and file is not exists
  if isFileExists(targetPath):
    return 1

  createDir(parentDir(targetPath))
  var f = open(targetPath, fmWrite)
  defer: f.close()
  f.write(USECASE)
  message = &"Created usecase in {targetPath}"
  styledWriteLine(stdout, fgGreen, bgDefault, message, resetStyle)


  targetCaptalized = snakeToCamel(dir)
  let targetProcCaptalized = snakeToCamelProcName(dir)
  let relativeToDatabasePath = "../".repeat(target.split("/").len) & &"../../../"
  let relativeToInterfacePath = "../".repeat(target.split("/").len-1) & &"../../../"

  let QUERY_INTERFACE = &"""
import asyncdispatch


type I{targetCaptalized}Query* = tuple
"""

  let QUERY_SERVICE = &"""
import asyncdispatch
import interface_implements
import allographer/query_builder
from {relativeToDatabasePath}config/database import rdb
import {relativeToInterfacePath}usecases/{dir}/{dir}_query_interface


type {targetCaptalized}Query* = ref object

proc new*(_:type {targetCaptalized}Query):{targetCaptalized}Query =
  return {targetCaptalized}Query()

implements {targetCaptalized}Query, I{targetCaptalized}Query:
  discard
"""

  let INTERFACE_PATH = &"{getCurrentDir()}/app/usecases/{dir}/{dir}_query_interface.nim"
  let IMPL_PATH = &"{getCurrentDir()}/app/data_stores/query_services/{dir}/{dir}_query.nim"

  # check dir and file is not exists
  if fileExists(INTERFACE_PATH) or fileExists(IMPL_PATH):
    return 1

  # query service interface
  targetPath = INTERFACE_PATH
  createDir(parentDir(targetPath))
  f = open(targetPath, fmWrite)
  f.write(QUERY_INTERFACE)
  message = &"Created query interface in {targetPath}"
  styledWriteLine(stdout, fgGreen, bgDefault, message, resetStyle)

  # query service
  targetPath = IMPL_PATH
  if isFileExists(targetPath): return 1
  createDir(parentDir(targetPath))
  f = open(targetPath, fmWrite)
  f.write(QUERY_SERVICE)
  message = &"Created query service in {targetPath}"
  styledWriteLine(stdout, fgGreen, bgDefault, message, resetStyle)

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
  textArr.insert(&"import data_stores/query_services/{dir}/{dir}_query", importOffset-1)
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
  textArr.insert(&"  {dir}Query: I{dirCaptalized}Query", importDifinisionOffset)
  # insert constructor
  textArr.insert(&"    {dir}Query: {dirCaptalized}Query.new().toInterface(),", textArr.len-4)
  # write in file
  f = open(targetPath, fmWrite)
  for i in 0..textArr.len-2:
    f.writeLine(textArr[i])
  message = &"Updated {targetPath}"
  styledWriteLine(stdout, fgGreen, bgDefault, message, resetStyle)

  return 0
