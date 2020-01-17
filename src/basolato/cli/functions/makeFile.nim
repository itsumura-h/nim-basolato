import os, terminal
import makeFile/controller
import makeFile/migration
import makeFile/config


template getTarget() =
  try:
    target = args[1]
  except:
    let message = "Missing args"
    styledWriteLine(stdout, fgRed, bgDefault, message, resetStyle)
    return 0

proc make*(args:seq[string]):int =
  ## make file
  var
    message:string
    todo:string
    target:string

  # check whether you are in dir includes main.nim
  let mainPath = getCurrentDir() & "/main.nim"
  if existsFile(mainPath) == false:
    let message = "Wrong directory. You should be in project root directory"
    styledWriteLine(stdout, fgRed, bgDefault, message, resetStyle)
    return 0

  try:
    todo = args[0]
  except:
    message = "Missing args"
    styledWriteLine(stdout, fgRed, bgDefault, message, resetStyle)
    return 0

  case todo:
  of "controller":
    getTarget
    return makeController(target, message)
  of "migration":
    getTarget
    return makeMigration(target, message)
  of "config":
    return makeConfig()
  else:
    message = "invalid things to make"
    styledWriteLine(stdout, fgRed, bgDefault, message, resetStyle)
