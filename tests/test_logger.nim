discard """
  cmd: "nim c -r -d:test $file"
"""

# nim c -r -d:test test_logger.nim

import std/unittest
import std/os
import std/strutils
import std/strformat
import ../src/basolato/settings
import ../src/basolato/core/logger

discard Settings.new(
  logToFile=true,
  errorLogToFile=true,
  logDir="./logs",
)

block:
  echoLog("test log message")
  let logPath = &"{LOG_DIR}/log.log"
  echo logPath
  check fileExists(logPath)
  let f = open(logPath)
  defer: close(f)
  let content = f.readAll()
  let contentArray = content.splitLines()
  check contentArray[^2].contains("test_logger: test log message")

block:
  echoErrorMsg("test log error message")
  let logPath = &"{LOG_DIR}/error.log"
  check fileExists(logPath)
  let f = open(logPath)
  defer: close(f)
  let content = f.readAll()
  let contentArray = content.splitLines()
  check contentArray[^2].contains("test_logger: ERROR test log error message")
