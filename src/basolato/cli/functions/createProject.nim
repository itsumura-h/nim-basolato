import os, strformat, terminal

const MAIN = """
import basolato/routing

import middleware/custom_headers
import basolato/sample/controllers/SampleController

routes:
  error Http404:
    http404Route

  error Exception:
    exceptionRoute

  get "/":
    route(SampleController.index())

runForever()
"""

const CUSTOM_HEADERS = """
from strutils import join

import basolato/middleware


proc corsHeader*(request: Request): seq =
  var headers = @[
    ("Cache-Control", "no-cache"),
    ("Access-Control-Allow-Origin", "*")
  ]

  var allowedMethods = [
    "OPTIONS",
    "GET",
    "POST",
    "PUT",
    "DELETE"
  ]
  if allowedMethods[0] != "":
    headers.add(("Access-Control-Allow-Methods", allowedMethods.join(", ")))

  var allowedHeaders = [
    "X-login-id"
  ]
  if allowedHeaders[0] != "":
    headers.add(("Access-Control-Allow-Headers", allowedHeaders.join(", ")))

  return headers
"""

const MIGRATION = """
import allographer/SchemaBuilder

Schema().create([
  Table().create("sample_users", [
    Column().increments("id"),
    Column().string("name"),
    Column().string("email")
  ])
])
"""


proc createMVC(packageDir:string):int =
  let dirPath = getCurrentDir() & "/" & packageDir
  let mainPath = dirPath & "/main.nim"
  let costomHeadersPath = dirPath & "/middleware/custom_headers.nim"
  let migrationPath = dirPath & "/migrations/0001migration.nim"

  try:
    createDir(dirPath)
    # main
    var f = open(mainPath, fmWrite)
    f.write(MAIN)

    createDir(dirPath & "/app")
    createDir(dirPath & "/app/controllers")
    createDir(dirPath & "/app/models")
    createDir(dirPath & "/middleware")
    createDir(dirPath & "/resources")
    createDir(dirPath & "/migrations")
    createDir(dirPath & "/public")
    discard execShellCmd(&"""
cd {packageDir}
dbtool makeConf
ducere make migration Init
""")

    # discard execShellCmd("ducere make migration Init")

    # custom_headers
    f = open(costomHeadersPath, fmWrite)
    f.write(CUSTOM_HEADERS)

    defer:
      f.close()
    return 0
  except:
    echo getCurrentExceptionMsg()
    return 1

proc createDDD() =
  echo ""

proc new*(args:seq[string], architecture="MVC"):int =
  ## create new project
  var
    message:string
    packageDir:string

  if args.len > 0 and args[0].len > 0:
    packageDir = args[0]
    let dirPath = getCurrentDir() & "/" & packageDir
    message = &"create project {dirPath}"
  else:
    message = &"create project {getCurrentDir()}"


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
