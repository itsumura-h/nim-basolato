import os, strformat, terminal, strutils

const MAIN = """
import shiotsuchi/routing

import app/controllers/SampleController

routes:
  get "/":
    route(SampleController.index())

runForever()
"""

const CONTROLLER = """
import shiotsuchi/controller

import ../../resources/sample/index

proc index*():Response =
  let name = "Shiotsuchi"
  return render(indexHtml(name))
"""

const HTML = r"""
import templates

proc indexHtml*(name:string): string = tmpli html'''
<h1>$(name) is successfully running!!!</h1>
'''
"""


proc createMVC(packageDir:string):int =
  let dirPath = getCurrentDir() & "/" & packageDir
  echo dirPath
  let mainPath = dirPath & "/main.nim"
  let controllerPath = dirPath & "/app/controllers/SampleController.nim"
  let htmlPath = dirPath & "/resources/sample/index.nim"

  try:
    block:
      createDir(dirPath & "/app")
      createDir(dirPath & "/app/controllers")
      createDir(dirPath & "/app/models")
      createDir(dirPath & "/config")
      createDir(dirPath & "/resources")
      createDir(dirPath & "/resources/sample")
      createDir(dirPath & "/migrations")
      createDir(dirPath & "/public")

      # main
      var f = open(mainPath, fmWrite)
      f.write(MAIN)

      # controller
      f = open(controllerPath, fmWrite)
      f.write(CONTROLLER)

      # html
      f = open(htmlPath, fmWrite)
      f.write(HTML.replace("'", "\""))

      defer:
        f.close()
      return 0
  except:
    echo getCurrentExceptionMsg()
    return 1

proc new*(args:seq[string], architecture="MVC"):int =
  ## create new project
  var
    message:string
    packageDir:string

  if args.len > 0 and args[0].len > 0:
    packageDir = args[0]
    message = &"create project {packageDir}"
  else:
    message = "create project here"


  case architecture:
  of "MVC":
    message.add("\ncreate as MVC")
    styledWriteLine(stdout, fgGreen, bgDefault, message, resetStyle)
    return createMVC(packageDir)
  of "DDD":
    message.add("\ncreate as DDD")
    styledWriteLine(stdout, fgGreen, bgDefault, message, resetStyle)
  else:
    message = """
invalid architecture.
MVC or DDD is only available.
MVC is set by default."""
    styledWriteLine(stdout, fgRed, bgDefault, message, resetStyle)
    return 1