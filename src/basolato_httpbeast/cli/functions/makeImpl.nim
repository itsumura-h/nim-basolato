import os, terminal
import
  make/controller, make/migration, make/view, make/config, make/model, make/usecase


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
  if fileExists(mainPath) == false:
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
  of "model":
    getTarget
    return makeModel(target, message)
  of "usecase":
    getTarget
    return makeUsecase(target, message)
  of "migration":
    getTarget
    return makeMigration(target, message)
  of "view":
    getTarget
    return makeView(target, message)
  of "config":
    return makeConfig()
  else:
    message = "invalid things to make"
    styledWriteLine(stdout, fgRed, bgDefault, message, resetStyle)
