import std/os
import std/times
import std/strformat
import std/strutils
import std/terminal
import utils


proc makeMigration*(target:string, message:var string):int =
  let now = now().format("yyyyMMddHHmmss")
  var targetPath = &"{getCurrentDir()}/database/migrations/default/migration_{now}_{target}.nim"
  # var targetPath = &"{getCurrentDir()}/database/migrations/migration_{target}.nim"

  if isFileExists(targetPath): return 0
  if isTargetContainSlash(target, "migration file name"): return 0

  createDir(parentDir(targetPath))

  var MIGRATION = &"""
import std/asyncdispatch
import std/json
import allographer/schema_builder
from ../../../config/database import rdb


proc {target}*() -[.async.]- =
  discard
"""
  MIGRATION = MIGRATION.multiReplace(("-[", "{"), ("]-", "}"))

  var f = open(targetPath, fmWrite)
  f.write(MIGRATION)
  f.close()

  message = &"Created migration {targetPath}"
  styledWriteLine(stdout, fgGreen, bgDefault, message, resetStyle)

  # update migrate.nim
  targetPath = &"{getCurrentDir()}/database/migrations/default/migrate.nim"
  f = open(targetPath, fmRead)
  let text = f.readAll()
  f.close()
  var textArr = text.splitLines()
  let migrationImport = &"import ./migration_{now}_{target}"

  proc leadingSpaces(row:string):int =
    while result < row.len and row[result] == ' ':
      inc result

  var importInsertIndex = textArr.len
  for i, row in textArr:
    if row.startsWith("import ") or row.startsWith("from "):
      importInsertIndex = i + 1
    elif row.strip.len == 0:
      break
    else:
      break
  if not textArr.contains(migrationImport):
    textArr.insert(migrationImport, importInsertIndex)

  var mainInsertIndex = textArr.len
  for i, row in textArr:
    if row.strip == "proc main*() {.async.} =":
      let mainIndent = leadingSpaces(row)
      var lastBodyIndex = -1
      for j in i + 1 ..< textArr.len:
        let bodyRow = textArr[j]
        if bodyRow.strip.len == 0:
          continue
        if leadingSpaces(bodyRow) > mainIndent:
          lastBodyIndex = j
          continue
        break
      if lastBodyIndex >= 0:
        mainInsertIndex = lastBodyIndex + 1
      else:
        mainInsertIndex = i + 1
      break
  textArr.insert(&"  {target}().await", mainInsertIndex)
  # delete discard
  for i, row in textArr:
    if row.contains("discard"):
      textArr.delete(i)
      break
  # write in file
  var normalizedTextArr: seq[string]
  var previousBlank = false
  for row in textArr:
    let isBlank = row.strip.len == 0
    if isBlank:
      if previousBlank:
        continue
      normalizedTextArr.add("")
      previousBlank = true
    else:
      normalizedTextArr.add(row)
      previousBlank = false
  while normalizedTextArr.len > 0 and normalizedTextArr[^1].strip.len == 0:
    normalizedTextArr.setLen(normalizedTextArr.len - 1)
  normalizedTextArr.add("")
  f = open(targetPath, fmWrite)
  defer: f.close()
  f.write(normalizedTextArr.join("\n"))
  message = &"Updated migrate.nim"
  styledWriteLine(stdout, fgGreen, bgDefault, message, resetStyle)
