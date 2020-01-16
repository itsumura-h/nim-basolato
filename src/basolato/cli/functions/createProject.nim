import os, strformat, terminal
import makeFile/utils

const MAIN = """
import basolato/routing

import middleware/custom_headers_middleware
import basolato/sample/controllers/SampleController

routes:
  error Http404:
    http404Route

  error Exception:
    exceptionRoute

  get "/":
    route(SampleController.index(), [corsHeader(), secureHeader()])

runForever()
"""

const CUSTOM_HEADERS_MIDDLEWARE = """
from strutils import join
import basolato/middleware


proc corsHeader*(): seq =
  var allowedMethods = @[
    "OPTIONS",
    "GET",
    "POST",
    "PUT",
    "DELETE"
  ]

  var allowedHeaders = @[
    "X-login-id",
    "X-login-token"
  ]

  return @[
    ("Cache-Control", "no-cache"),
    ("Access-Control-Allow-Origin", "*"),
    ("Access-Control-Allow-Methods", allowedMethods.join(", ")),
    ("Access-Control-Allow-Headers", allowedHeaders.join(", "))
  ]


proc secureHeader*(): seq =
  return @[
    ("Strict-Transport-Security", ["max-age=63072000", "includeSubdomains"].join(", ")),
    ("X-Frame-Options", "SAMEORIGIN"),
    ("X-XSS-Protection", ["1", "mode=block"].join(", ")),
    ("X-Content-Type-Options", "nosniff"),
    ("Referrer-Policy", ["no-referrer", "strict-origin-when-cross-origin"].join(", ")),
    ("Cache-control", ["no-cache", "no-store", "must-revalidate"].join(", ")),
    ("Pragma", "no-cache"),
  ]
"""

const MIGRATION = """
import json, strformat
import allographer/schema_builder
import allographer/query_builder

proc migration0001*() =
  Schema().create([
    Table().create("sample_users", [
      Column().increments("id"),
      Column().string("name"),
      Column().string("email")
    ])
  ])

  var users: seq[JsonNode]
  for i in 1..10:
    users.add(%*{
      "id": i,
      "name": &"user{i}",
      "email": &"user{i}@nim.com"
    })
  RDB().table("sample_users").insert(users)
"""


proc createMVC(packageDir:string):int =
  let dirPath = getCurrentDir() & "/" & packageDir
  let mainPath = dirPath & "/main.nim"
  let costomHeadersPath = dirPath & "/middleware/custom_headers_middleware.nim"
  let migrationPath = dirPath & "/migrations/migration0001.nim"
  let migratePath = dirPath & "/migrations/migrate.nim"

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
ducere make config
""")

    # discard execShellCmd("ducere make migration Init")

    # custom_headers
    f = open(costomHeadersPath, fmWrite)
    f.write(CUSTOM_HEADERS_MIDDLEWARE)

    # migration
    f = open(migrationPath, fmWrite)
    f.write(MIGRATION)

    # migrate
    let MIGRATE = """
import migration0001

proc main() =
  migration0001()

main()
"""
    f = open(migratePath, fmWrite)
    f.write(MIGRATE)

    defer:
      f.close()
    return 0
  except:
    echo getCurrentExceptionMsg()
    return 1

proc createDDD():int =
  return 0

proc new*(args:seq[string], architecture="MVC"):int =
  ## create new project
  var
    message:string
    packageDir:string

  if args.len > 0 and args[0].len > 0:
    packageDir = args[0]
    let dirPath = getCurrentDir() & "/" & packageDir
    if isDirExists(dirPath): return 0
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
    return createDDD()
  else:
    message = """
invalid architecture.
MVC or DDD is only available.
MVC is set by default."""
    styledWriteLine(stdout, fgRed, bgDefault, message, resetStyle)
    return 1
