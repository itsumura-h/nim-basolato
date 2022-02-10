import os, strformat, terminal, strutils
from ../../core/base import BasolatoVersion
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
    # get from tmp/0.12
    moveDir(&"{dirpath}/tmp/0.12/app", &"{dirpath}/app")
    moveDir(&"{dirpath}/tmp/0.12/config", &"{dirpath}/config")
    moveDir(&"{dirpath}/tmp/0.12/database", &"{dirpath}/database")
    moveDir(&"{dirpath}/tmp/0.12/public", &"{dirpath}/public")
    moveDir(&"{dirpath}/tmp/0.12/resources", &"{dirpath}/resources")
    moveFile(&"{dirpath}/tmp/0.12/main.nim", &"{dirpath}/main.nim")
    moveFile(&"{dirpath}/tmp/0.12/.gitignore", &"{dirpath}/.gitignore")
    # move static files
    moveFile(&"{dirpath}/tmp/assets/basolato.svg", &"{dirpath}/public/basolato.svg")
    moveFile(&"{dirpath}/tmp/assets/favicon.ico", &"{dirpath}/public/favicon.ico")
    # remove tmp
    removeDir(&"{dirpath}/tmp")
    # create .env
    discard execShellCmd(&"""
  cd {dirPath}
  ducere make config
  """)

    # create empty dirs
    createDir(&"{dirPath}/app/http/views/errors")
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
requires "https://github.com/itsumura-h/nim-basolato >= {BasolatoVersion}"
requires "allographer >= 0.19.2"
requires "interface_implements >= 0.2.2"
requires "bcrypt >= 0.2.1"
requires "cligen >= 1.5.9"
requires "faker >= 0.14.0"
requires "flatdb >= 0.2.5"
requires "nimAES >= 0.1.2"
requires "redis >= 0.3.0"
requires "sass >= 0.1.0"
requires "templates >= 0.5"

task test, "run testament":
  echo staticExec("testament p \"./tests/test_*.nim\"")
  discard staticExec("find tests/ -type f ! -name \"*.*\" -delete 2> /dev/null")
"""
    block:
      let f = open(&"{dirPath}/{packageDir}.nimble", fmWrite)
      defer: f.close()
      f.write(nimble)

    let test = """
import unittest

block sampleTest:
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
    removeDir(dirPath)
    return 1

proc new*(args:seq[string]):int =
  ## Create new project
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
