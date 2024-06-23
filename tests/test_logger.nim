discard """
  cmd: "nim c -r -d:test $file"
"""

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
  echo "LOG_DIR: ",LOG_DIR
  echo "LOG_TO_FILE: ",LOG_TO_FILE
  echoLog("test log message")
  let logPath = &"{LOG_DIR}/log.log"
  echo logPath
  check fileExists(logPath)
  let f = open(logPath)
  defer: close(f)
  let content = f.readAll()
  echo content
  let contentArray = content.splitLines()
  let length = contentArray.len()
  check contentArray[length-2].contains("test_logger: test log message")

block:
  echo "LOG_DIR: ",LOG_DIR
  echo "ERROR_LOG_TO_FILE: ",ERROR_LOG_TO_FILE
  echoErrorMsg("test log error message")
  let logPath = &"{LOG_DIR}/error.log"
  check fileExists(logPath)
  let f = open(logPath)
  defer: close(f)
  let content = f.readAll()
  let contentArray = content.splitLines()
  let length = contentArray.len()
  check contentArray[length-2].contains("test_logger: test log error message")
