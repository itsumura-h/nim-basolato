import os, strformat, strutils, terminal, random

proc isFileExists*(targetPath:string):bool =
  if existsFile(targetPath):
    let message = &"{targetPath} is already exists"
    styledWriteLine(stdout, fgRed, bgDefault, message, resetStyle)
    return true
  else:
    return false

proc isDirExists*(targetPath:string):bool =
  if existsDir(targetPath):
    let message = &"{targetPath} is already exists"
    styledWriteLine(stdout, fgRed, bgDefault, message, resetStyle)
    return true
  else:
    return false

proc isTargetContainSlash*(target:string):bool =
  if target.contains("/"):
    let message = &"Don't contain \"/\" in migration file name"
    styledWriteLine(stdout, fgRed, bgDefault, message, resetStyle)
    return true
  else:
    return false

proc rundStr*(n:openArray[int]):string =
  randomize()
  var n = n.sample()
  for _ in 1..n:
    add(result, char(rand(int('0')..int('z'))))
