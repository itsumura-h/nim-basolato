import std/logging
import std/os
import std/terminal
import ./settings


let consoleLogger = newConsoleLogger()

proc echoLog*(output: auto, args:varargs[string]) =
  {.cast(gcsafe).}: # fix: "which is a global using GC'ed memory" in server.nim
    if LOG_TO_CONSOLE:
      consoleLogger.log(lvlDebug, $output & $args)
    if LOG_TO_FILE:
      let path = LOG_DIR / "log.log"
      createDir(parentDir(path))
      let fileLogger = newRollingFileLogger(path, mode=fmAppend, fmtStr=verboseFmtStr)
      defer: fileLogger.file.close()
      fileLogger.log(lvlInfo, $output & $args)
      flushFile(fileLogger.file)


proc echoErrorMsg*(msg:string) =
  {.cast(gcsafe).}: # fix: "which is a global using GC'ed memory" in server.nim
    let logDir = LOG_DIR
    # console log
    if LOG_TO_CONSOLE:
      styledWriteLine(stdout, fgRed, bgDefault, msg, resetStyle)
    # file log
    if ERROR_LOG_TO_FILE:
      let path = logDir / "error.log"
      createDir(parentDir(path))
      let fileLogger = newRollingFileLogger(path, mode=fmAppend, fmtStr=verboseFmtStr)
      defer: fileLogger.file.close()
      fileLogger.log(lvlError, msg)
      flushFile(fileLogger.file)
