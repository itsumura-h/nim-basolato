import os, terminal, strutils
import
  make/config, make/key, make/migration, make/seeder,
  make/controller, make/usecase, make/query, make/model, make/valueobject,
  make/layout, make/page


template getArg1() =
  try:
    arg1 = args[1]
  except:
    let message = "Missing args"
    styledWriteLine(stdout, fgRed, bgDefault, message, resetStyle)
    return 0

template getArg2() =
  try:
    arg2 = args[2]
  except:
    let message = "Missing args"
    styledWriteLine(stdout, fgRed, bgDefault, message, resetStyle)
    return 0

proc make*(args:seq[string]):int =
  ## make file
  var
    message:string
    todo:string
    arg1:string
    arg2:string

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
  of "key":
    return makeKey()
  of "controller":
    getArg1
    return makeController(arg1, message)
  of "model":
    getArg1
    return makeModel(arg1, message)
  of "valueobject":
    message = "'valueobject' is deprecated. use 'vo'"
    styledWriteLine(stdout, fgYellow, bgDefault, message, resetStyle)
    getArg1
    getArg2
    return makeValueObject(arg1, arg2, message)
  of "vo":
    getArg1
    getArg2
    return makeValueObject(arg1, arg2, message)
  of "usecase":
    getArg1
    getArg2
    if arg2.contains("/"):
      message = "target should not contains '/'"
      styledWriteLine(stdout, fgRed, bgDefault, message, resetStyle)
      return 0
    return makeUsecase(arg1, arg2, message)
  of "query":
    getArg1
    return makeQuery(arg1, message)
  of "migration":
    getArg1
    return makeMigration(arg1, message)
  of "seeder":
    getArg1
    return makeSeeder(arg1, message)
  of "layout":
    getArg1
    return makelayout(arg1, message)
  of "page":
    getArg1
    return makePage(arg1, message)
  else:
    message = "invalid things to make"

  styledWriteLine(stdout, fgRed, bgDefault, message, resetStyle)
