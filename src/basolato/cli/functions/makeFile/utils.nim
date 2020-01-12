import os, strformat, strutils, terminal

proc isFileExists*(targetPath:string):bool =
  if existsFile(targetPath):
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