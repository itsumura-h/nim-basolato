discard """
  cmd: "nim c -r -d:test $file"
"""
# nim c -r -d:test tests/test_build_options.nim


import std/os
import std/osproc
import std/strformat
import std/unittest


proc checkServerBuild(label, defineFlag: string) =
  let
    serverDir = currentSourcePath().parentDir() / "server"
    outputPath = getTempDir() / &"basolato-server-build-{label}-{getCurrentProcessId()}"
    command = &"ducere build {defineFlag}"

  try:
    let (output, exitCode) = execCmdEx(
      command,
      options = {poStdErrToStdOut, poUsePath},
      workingDir = serverDir,
    )
    echo output

    if exitCode != 0:
      echo output

    check exitCode == 0
  finally:
    if fileExists(outputPath):
      removeFile(outputPath)


suite("server build options"):
  test("asynchttpserver build"):
    checkServerBuild("asynchttpserver", "")

  test("httpx build"):
    checkServerBuild("httpx", "--httpx")

  test("httpbeast build"):
    checkServerBuild("httpbeast", "--httpbeast")
