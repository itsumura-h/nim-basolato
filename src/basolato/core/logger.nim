import std/logging
import std/os
import std/terminal
import ./settings


let consoleLogger = newConsoleLogger()

var fileLogger: RollingFileLogger
var fileLoggerReady = false
var errorFileLogger: RollingFileLogger
var errorFileLoggerReady = false

proc ensureFileLogger() =
  if fileLoggerReady:
    return
  let path = LOG_DIR / "log.log"
  createDir(parentDir(path))
  fileLogger = newRollingFileLogger(path, mode=fmAppend, fmtStr=verboseFmtStr)
  fileLoggerReady = true

proc ensureErrorFileLogger() =
  if errorFileLoggerReady:
    return
  let path = LOG_DIR / "error.log"
  createDir(parentDir(path))
  errorFileLogger = newRollingFileLogger(path, mode=fmAppend, fmtStr=verboseFmtStr)
  errorFileLoggerReady = true

proc echoLog*(output: auto) =
  {.cast(gcsafe).}: # fix: "which is a global using GC'ed memory" in server.nim
    if LOG_TO_CONSOLE:
      consoleLogger.log(lvlDebug, $output)
    if LOG_TO_FILE:
      ensureFileLogger()
      fileLogger.log(lvlDebug, $output)
      flushFile(fileLogger.file)


proc echoErrorMsg*(output: auto) =
  {.cast(gcsafe).}: # fix: "which is a global using GC'ed memory" in server.nim
    # console log
    if LOG_TO_CONSOLE:
      let output = "ERROR " & $output
      styledWriteLine(stdout, fgRed, bgDefault, output, resetStyle)
    # file log
    if ERROR_LOG_TO_FILE:
      ensureErrorFileLogger()
      errorFileLogger.log(lvlError, $output)
      flushFile(errorFileLogger.file)
