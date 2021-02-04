import os, strformat, terminal, strutils
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
    # get from tmp/0.9
    moveDir(&"{dirpath}/tmp/0.9/app", &"{dirpath}/app")
    moveDir(&"{dirpath}/tmp/0.9/migrations", &"{dirpath}/migrations")
    moveDir(&"{dirpath}/tmp/0.9/public", &"{dirpath}/public")
    # moveDir(&"{dirpath}/tmp/0.9/resources", &"{dirpath}/resources")
    moveFile(&"{dirpath}/tmp/0.9/main.nim", &"{dirpath}/main.nim")
    moveFile(&"{dirpath}/tmp/0.9/.gitignore", &"{dirpath}/.gitignore")
    # move static files
    moveFile(&"{dirpath}/tmp/assets/basolato.svg", &"{dirpath}/public/basolato.svg")
    moveFile(&"{dirpath}/tmp/assets/favicon.ico", &"{dirpath}/public/favicon.ico")
    # remove tmp
    removeDir(&"{dirpath}/tmp")
    # create config.nims
    discard execShellCmd(&"""
  cd {dirPath}
  ducere make config
  cp config.nims config.nims.dev
  cp config.nims config.nims.stg
  cp config.nims config.nims.prd
  """)
    # create session.db
    block:
      let f = open(&"{dirPath}/session.db", fmWrite)
      defer: f.close()
      f.write("")
    # create empty dirs
    createDir(&"{dirPath}/resources/errors")
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

    let test = """
import unittest

suite "test suite":
  test "sample":
    check true
"""
    block:
      let f = open(&"{dirPath}/tests/test_sample.nim", fmWrite)
      defer: f.close()
      f.write(test)

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

  try:
    if args[0] == ".":
      dirPath = getCurrentDir()
      packageDir = dirPath.split("/")[^1]
    else:
      packageDir = args[0]
      dirPath = getCurrentDir() & "/" & packageDir
      if isDirExists(dirPath): return 0
  except:
    message = "Missing args"
    styledWriteLine(stdout, fgRed, bgDefault, message, resetStyle)
    return 0

  message = &"create project {dirPath}"

  return create(dirPath, packageDir)
