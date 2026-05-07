discard """
  cmd: "nim c -r -d:test $file"
"""
# nim c -r -d:test tests/test_build_options.nim


import std/os
import std/osproc
import std/strformat
import std/unittest


proc checkServerBuild(label, defineFlag: string):int =
  let
    serverDir = currentSourcePath().parentDir() / "server"
    command = &"ducere build {defineFlag}"

  let (output, exitCode) = execCmdEx(
    command,
    options = {poStdErrToStdOut, poUsePath},
    workingDir = serverDir,
  )

  if exitCode != 0:
    echo output

  return exitCode


suite("server build options"):
  test("asynchttpserver build"):
    let exitCode = checkServerBuild("asynchttpserver", "")
    check exitCode == 0

  test("httpx build"):
    let exitCode = checkServerBuild("httpx", "--httpx")
    check exitCode == 0

  test("httpbeast build"):
    let exitCode = checkServerBuild("httpbeast", "--httpbeast")
    check exitCode == 0
