import os, strformat, strutils, terminal
import makeFile/controller
import makeFile/migration


proc make*(args:seq[string]):int =
  ## make file
  var
    message:string
    todo:string
    target:string

  # check whether you are in dir includes main.nim
  let mainPath = getCurrentDir() & "/main.nim"
  if existsFile(mainPath) == false:
    message = "Wrong directory. You should be in project root directory"
    styledWriteLine(stdout, fgRed, bgDefault, message, resetStyle)
    return 0

  try:
    todo = args[0]
    target = args[1]
  except:
    message = "Missing args"
    styledWriteLine(stdout, fgRed, bgDefault, message, resetStyle)
    return 0

  case todo:
  of "controller":
    return makeController(target, message)
  of "migration":
    return makeMigration(target, message)
  else:
    message = "invalid things to make"
    styledWriteLine(stdout, fgRed, bgDefault, message, resetStyle)
  