import os, strformat, terminal
from ../../core/base import basolatoVersion
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
    # get from tmp/0.6
    moveDir(&"{dirpath}/tmp/0.6/app", &"{dirpath}/app")
    moveDir(&"{dirpath}/tmp/0.6/migrations", &"{dirpath}/migrations")
    moveDir(&"{dirpath}/tmp/0.6/public", &"{dirpath}/public")
    moveDir(&"{dirpath}/tmp/0.6/resources", &"{dirpath}/resources")
    moveFile(&"{dirpath}/tmp/0.6/main.nim", &"{dirpath}/main.nim")
    moveFile(&"{dirpath}/tmp/0.6/.gitignore", &"{dirpath}/.gitignore")
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
    # create session.db
    block:
      let f = open(&"{dirPath}/session.db", fmWrite)
      defer: f.close()
      f.write("")
    # create empty dirs
    createDir(&"{dirPath}/resources/pages")
    createDir(&"{dirPath}/resources/layouts")
    createDir(&"{dirPath}/tests")
    createDir(&"{dirPath}/public/js")
    createDir(&"{dirPath}/public/css")
    # create nimble file
    let nimble = &"""
# Package
version       = "0.1.0"
author        = "Anonymous"
description   = "A new awesome basolato package"
license       = "MIT"
srcDir        = "."
bin           = @["main"]
backend       = "c"
# Dependencies
requires "nim >= {NimVersion}"
requires "https://github.com/itsumura-h/nim-basolato >= {basolatoVersion}"
requires "cligen >= 0.9.41"
requires "templates >= 0.5"
requires "bcrypt >= 0.2.1"
requires "nimAES >= 0.1.2"
requires "flatdb >= 0.2.4"
requires "allographer >= 0.9.0"
requires "faker >= 0.12.1"
"""
    block:
      let f = open(&"{dirPath}/{packageDir}.nimble", fmWrite)
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
