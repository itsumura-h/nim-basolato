import os, strformat, terminal, strutils
import utils

proc makeSeeder*(target:string, message:var string):int =
  var targetPath = &"{getCurrentDir()}/database/seeders/seeder_{target}.nim"

  if isFileExists(targetPath): return 0
  if isTargetContainSlash(target, "seeder file name"): return 0

  createDir(parentDir(targetPath))

  var SEEDER = &"""
import std/asyncdispatch
import std/json
import allographer/query_builder
from ../../config/database import rdb


proc {target}*() [[.async.]] =
  seeder rdb, "{target}":
    var data: seq[JsonNode]
    await rdb.table("{target}").insert(data)
"""
  SEEDER = SEEDER.multiReplace(("[[", "{"), ("]]", "}"))

  var f = open(targetPath, fmWrite)
  f.write(SEEDER)
  f.close()

  message = &"Created seeder {targetPath}"
  styledWriteLine(stdout, fgGreen, bgDefault, message, resetStyle)

  # update seeder.nim
  targetPath = &"{getCurrentDir()}/database/seeders/seed.nim"
  f = open(targetPath, fmRead)
  let text = f.readAll()
  var textArr = text.splitLines()
  # get offset where column is empty string
  var offsets:seq[int]
  for i, row in textArr:
    if row == "":
      offsets.add(i)
  # insert array
  textArr.insert(&"import ./seeder_{target}", offsets[0])
  textArr.insert(&"  waitFor {target}()", offsets[1]+1)
  # write in file
  f = open(targetPath, fmWrite)
  defer: f.close()
  for i in 0..textArr.len-2:
    f.writeLine(textArr[i])
  message = &"Updated seed.nim"
  styledWriteLine(stdout, fgGreen, bgDefault, message, resetStyle)
