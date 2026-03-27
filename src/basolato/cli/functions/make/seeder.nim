import os, strformat, terminal, strutils
import utils

proc makeSeeder*(target:string, message:var string):int =
  var targetPath = &"{getCurrentDir()}/database/seeders/data/seeder_{target}.nim"

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

  let importLine = &"import ./data/seeder_{target}"
  let callLine = &"    {target}().await"

  for seederMain in ["develop.nim", "staging.nim", "production.nim"]:
    targetPath = &"{getCurrentDir()}/database/seeders/{seederMain}"
    f = open(targetPath, fmRead)
    var text = f.readAll()
    f.close()

    if not text.contains(importLine):
      text = text.replace("import ./data/sample_seeder\n", &"import ./data/sample_seeder\n{importLine}\n")

    if not text.contains(callLine):
      text = text.replace("    sampleSeeder().await\n", &"    sampleSeeder().await\n{callLine}\n")

    f = open(targetPath, fmWrite)
    f.write(text)
    f.close()

    message = &"Updated {targetPath}"
    styledWriteLine(stdout, fgGreen, bgDefault, message, resetStyle)
