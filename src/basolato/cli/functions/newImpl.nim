import std/os
import std/strformat
import std/strutils
import std/terminal
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
  cd tmp
  git switch v0.16.0
  cd ../
  """)
    const version = "0.16"
    # get from tmp/{version}
    moveDir(&"{dirpath}/tmp/{version}/app", &"{dirpath}/app")
    moveDir(&"{dirpath}/tmp/{version}/config", &"{dirpath}/config")
    moveDir(&"{dirpath}/tmp/{version}/database", &"{dirpath}/database")
    moveDir(&"{dirpath}/tmp/{version}/public", &"{dirpath}/public")
    moveDir(&"{dirpath}/tmp/{version}/resources", &"{dirpath}/resources")
    moveFile(&"{dirpath}/tmp/{version}/main.nim", &"{dirpath}/main.nim")
    moveFile(&"{dirpath}/tmp/{version}/.gitignore", &"{dirpath}/.gitignore")
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
requires "allographer >= 0.21.0"
requires "interface_implements >= 0.2.2"
requires "bcrypt >= 0.2.1"
requires "cligen >= 1.5.9"
requires "faker >= 0.14.0"
requires "redis >= 0.3.0"
requires "sass >= 0.1.0"

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
