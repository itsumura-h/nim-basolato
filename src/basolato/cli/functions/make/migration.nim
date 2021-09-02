import os, strformat, terminal, times, strutils
import utils

proc makeMigration*(target:string, message:var string):int =
  let now = now().format("yyyyMMddHHmmss")
  var targetPath = &"{getCurrentDir()}/migrations/migration{now}{target}.nim"

  if isFileExists(targetPath): return 0
  if isTargetContainSlash(target, "migration file name"): return 0

  createDir(parentDir(targetPath))

  var MIGRATION = &"""
import asyncdispatch, json
import allographer/schema_builder
import allographer/query_builder
from ../database import rdb


proc migration{now}{target}*() [.async.] =
  discard
"""
  MIGRATION = MIGRATION.multiReplace(("[", "{"), ("]", "}"))

  var f = open(targetPath, fmWrite)
  f.write(MIGRATION)
  f.close()

  message = &"Created migration {targetPath}"
  styledWriteLine(stdout, fgGreen, bgDefault, message, resetStyle)

  # update migrate.nim
  targetPath = &"{getCurrentDir()}/migrations/migrate.nim"
  f = open(targetPath, fmRead)
  let text = f.readAll()
  var textArr = text.splitLines()
  # get offset where column is empty string
  var offsets:seq[int]
  for i, row in textArr:
    if row == "":
      offsets.add(i)
  # insert array
  textArr.insert(&"import migration{now}{target}", offsets[0])
  textArr.insert(&"  waitFor migration{now}{target}()", offsets[1]+1)
  # write in file
  f = open(targetPath, fmWrite)
  defer: f.close()
  for i in 0..textArr.len-2:
    f.writeLine(textArr[i])
  message = &"Updated migrate.nim"
  styledWriteLine(stdout, fgGreen, bgDefault, message, resetStyle)
