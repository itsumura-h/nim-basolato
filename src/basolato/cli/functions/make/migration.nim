import std/os
import std/strformat
import std/strutils
import std/terminal
import utils


proc makeMigration*(target:string, message:var string):int =
  # let now = now().format("yyyyMMddHHmmss")
  # var targetPath = &"{getCurrentDir()}/database/migrations/migration{now}{target}.nim"
  var targetPath = &"{getCurrentDir()}/database/migrations/migration_{target}.nim"

  if isFileExists(targetPath): return 0
  if isTargetContainSlash(target, "migration file name"): return 0

  createDir(parentDir(targetPath))

  var MIGRATION = &"""
import std/asyncdispatch
import std/json
import allographer/schema_builder
from ../../config/database import rdb


proc {target}*() [.async.] =
  discard
"""
  MIGRATION = MIGRATION.multiReplace(("[", "{"), ("]", "}"))

  var f = open(targetPath, fmWrite)
  f.write(MIGRATION)
  f.close()

  message = &"Created migration {targetPath}"
  styledWriteLine(stdout, fgGreen, bgDefault, message, resetStyle)

  # update migrate.nim
  targetPath = &"{getCurrentDir()}/database/migrations/migrate.nim"
  f = open(targetPath, fmRead)
  let text = f.readAll()
  var textArr = text.splitLines()
  # get offset where column is empty string
  var offsets:seq[int]
  for i, row in textArr:
    if row == "":
      offsets.add(i)
  # insert array
  textArr.insert(&"import ./migration_{target}", offsets[0])
  textArr.insert(&"  waitFor {target}()", offsets[1]+1)
  # write in file
  f = open(targetPath, fmWrite)
  defer: f.close()
  for i in 0..textArr.len-2:
    f.writeLine(textArr[i])
  message = &"Updated migrate.nim"
  styledWriteLine(stdout, fgGreen, bgDefault, message, resetStyle)
