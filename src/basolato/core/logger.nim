import std/logging
import std/os
import std/terminal
import ./settings


let consoleLogger = newConsoleLogger()

proc echoLog*(output: auto) =
  {.cast(gcsafe).}: # fix: "which is a global using GC'ed memory" in server.nim
    if LOG_TO_CONSOLE:
      consoleLogger.log(lvlDebug, $output)
    if LOG_TO_FILE:
      let path = LOG_DIR / "log.log"
      createDir(parentDir(path))
      let fileLogger = newRollingFileLogger(path, mode=fmAppend, fmtStr=verboseFmtStr)
      defer: fileLogger.file.close()
      fileLogger.log(lvlDebug, $output)
      flushFile(fileLogger.file)


proc echoErrorMsg*(output: auto) =
  {.cast(gcsafe).}: # fix: "which is a global using GC'ed memory" in server.nim
    let logDir = LOG_DIR
    # console log
    if LOG_TO_CONSOLE:
      let output = "ERROR " & $output
      styledWriteLine(stdout, fgRed, bgDefault, output, resetStyle)
      # consoleLogger.log(lvlError, msg)
    # file log
    if ERROR_LOG_TO_FILE:
      let path = logDir / "error.log"
      createDir(parentDir(path))
      let fileLogger = newRollingFileLogger(path, mode=fmAppend, fmtStr=verboseFmtStr)
      defer: fileLogger.file.close()
      let output = "ERROR " & $output
      fileLogger.log(lvlError, $output)
      flushFile(fileLogger.file)
