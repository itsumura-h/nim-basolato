import os, strformat, terminal, strutils
from ../../base import basolatoVersion
from make/utils import isDirExists

proc create(dirPath:string, packageDir:string):int =
  try:
    createDir(dirPath)
    # download from github as dir name tmp
    let tmplateGitUrl = "https://github.com/itsumura-h/nim-basolato-templates"
    discard execShellCmd(&"""
  cd {dirPath}
  git clone {tmplateGitUrl} tmp
  """)
    # get from tmp/MVC
    moveDir(&"{dirpath}/tmp/MVC/app", &"{dirpath}/app")
    moveDir(&"{dirpath}/tmp/MVC/migrations", &"{dirpath}/migrations")
    moveDir(&"{dirpath}/tmp/MVC/public", &"{dirpath}/public")
    moveDir(&"{dirpath}/tmp/MVC/resources", &"{dirpath}/resources")
    moveFile(&"{dirpath}/tmp/MVC/main.nim", &"{dirpath}/main.nim")
    # move static files
    moveFile(&"{dirpath}/tmp/assets/basolato.svg", &"{dirpath}/public/basolato.svg")
    moveFile(&"{dirpath}/tmp/assets/favicon.ico", &"{dirpath}/public/favicon.ico")
    # remove tmp
    removeDir(&"{dirpath}/tmp")
    # create config.nims
    discard execShellCmd(&"""
  cd {dirPath}
  ducere make config
  """)
    # create empty dirs
    createDir(&"{dirPath}/tests")
    createDir(&"{dirPath}/public/js")
    createDir(&"{dirPath}/public/css")
    # create nimble file
    var nimble = &"""
# Package

version       = "0.1.0"
author        = "Anonymous"
description   = "A new awesome baspolato package"
license       = "MIT"
srcDir        = "."
bin           = @["main"]

backend       = "c"

# Dependencies

requires "nim >= {NimVersion}"
requires "basolato >= {basolatoVersion}"
requires "httpbeast >= 0.2.2"
requires "cligen >= 0.9.41"
requires "templates >= 0.5"
requires "bcrypt >= 0.2.1"
requires "nimAES >= 0.1.2"
requires "https://github.com/enthus1ast/flatdb >= 0.2.4"
requires "allographer >= 0.9.0"
"""
    block:
      var f = open(&"{dirPath}/{packageDir}.nimble", fmWrite)
      defer: f.close()
      f.write(nimble)

    styledEcho(fgBlack, bgGreen, &"[Success] Created project in {dirpath} ", resetStyle)
    return 0
  except:
    echo getCurrentExceptionMsg()
    return 1

proc new*(args:seq[string]):int =
  ## create new project
  var
    message:string
    packageDir:string
    dirPath:string

  if args.len > 0 and args[0].len > 0:
    packageDir = args[0]
    dirPath = getCurrentDir() & "/" & packageDir
    if isDirExists(dirPath): return 0
    message = &"create project {dirPath}"
  else:
    dirPath = getCurrentDir()
    message = &"create project {getCurrentDir()}"

  return create(dirPath, packageDir)
