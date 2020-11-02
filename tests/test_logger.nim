import unittest, os, strformat, strutils
from ../src/basolato/core/baseEnv import LOG_DIR
import ../src/basolato/core/logger


suite "logger":
  test "logger":
    logger("test log message")
    check existsFile(&"{LOG_DIR}/log.log")

    let f = open(&"{LOG_DIR}/log.log")
    defer: close(f)
    let content = f.readAll()
    let contentArray = content.splitLines()
    let length = contentArray.len()
    check contentArray[length-2].contains("test_logger: test log message")

  test "echoErrorMsg":
    echoErrorMsg("test log error message")
    check existsFile(&"{LOG_DIR}/error.log")

    let f = open(&"{LOG_DIR}/error.log")
    defer: close(f)
    let content = f.readAll()
    let contentArray = content.splitLines()
    let length = contentArray.len()
    check contentArray[length-2].contains("test_logger: test log error message")
