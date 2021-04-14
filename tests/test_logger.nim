import unittest, os, strformat, strutils
from ../src/basolato/core/baseEnv import LOG_DIR
import ../src/basolato/core/logger

block:
  echoLog("test log message")
  check fileExists(&"{LOG_DIR}/log.log")
  let f = open(&"{LOG_DIR}/log.log")
  defer: close(f)
  let content = f.readAll()
  let contentArray = content.splitLines()
  let length = contentArray.len()
  check contentArray[length-2].contains("test_logger: test log message")

block:
  echoErrorMsg("test log error message")
  check fileExists(&"{LOG_DIR}/error.log")
  let f = open(&"{LOG_DIR}/error.log")
  defer: close(f)
  let content = f.readAll()
  let contentArray = content.splitLines()
  let length = contentArray.len()
  check contentArray[length-2].contains("test_logger: test log error message")
