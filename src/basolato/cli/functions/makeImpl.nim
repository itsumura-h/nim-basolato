import os, terminal
import
  make/config, make/migration, make/controller,
  make/usecase, make/model, make/valueobject,
  make/layout, make/page


template getTarget() =
  try:
    target = args[1]
  except:
    let message = "Missing args"
    styledWriteLine(stdout, fgRed, bgDefault, message, resetStyle)
    return 0

template getTargetPath() =
  try:
    targetPath = args[2]
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
    targetPath:string

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
  of "config":
    return makeConfig()
  of "migration":
    getTarget
    return makeMigration(target, message)
  of "controller":
    getTarget
    return makeController(target, message)
  of "usecase":
    getTarget
    return makeUsecase(target, message)
  of "model":
    getTarget
    return makeModel(target, message)
  of "valueobject":
    getTarget
    getTargetPath
    return makeValueObject(target, targetPath, message)
  of "layout":
    getTarget
    return makelayout(target, message)
  of "page":
    getTarget
    return makePage(target, message)
  else:
    message = "invalid things to make"
    styledWriteLine(stdout, fgRed, bgDefault, message, resetStyle)
