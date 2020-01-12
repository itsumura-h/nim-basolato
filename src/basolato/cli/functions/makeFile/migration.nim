import os, strformat, strutils, terminal, times
import utils

proc makeMigration*(target:string, message:var string):int =
  let now = now().format("yyyyMMddHHmmss")
  let targetPath = &"{getCurrentDir()}/migrations/migration{now}{target}.nim"

  if isFileExists(targetPath): return 0
  if isTargetContainSlash(target): return 0

  createDir(parentDir(targetPath))

  let MIGRATION = &"""
import json, strformat

import allographer/schema_builder
import allographer/query_builder

proc migration{now}{target}*() =
  discard
"""

  var f = open(targetPath, fmWrite)
  f.write(MIGRATION)
  defer: f.close()

  message = &"create migration {now}{target}"
  styledWriteLine(stdout, fgGreen, bgDefault, message, resetStyle)
  return 1