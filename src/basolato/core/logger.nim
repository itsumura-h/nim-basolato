import std/logging
import std/os
import std/terminal
import ./baseEnv


proc echoLog*(output: auto, args:varargs[string]) =
  {.cast(gcsafe).}: # fix: "which is a global using GC'ed memory" in server.nim
    if IS_DISPLAY:
      when not defined(release):
        let logger = newConsoleLogger()
        logger.log(lvlDebug, $output & $args)
    if IS_FILE:
      let path = LOG_DIR & "/log.log"
      createDir(parentDir(path))
      let logger = newRollingFileLogger(path, mode=fmAppend, fmtStr=verboseFmtStr)
      defer: logger.file.close()
      logger.log(lvlInfo, $output & $args)
      flushFile(logger.file)


proc echoErrorMsg*(msg:string) =
  {.cast(gcsafe).}: # fix: "which is a global using GC'ed memory" in server.nim
    let logDir = LOG_DIR
    # console log
    if IS_DISPLAY:
      when not defined(release):
        styledWriteLine(stdout, fgRed, bgDefault, msg, resetStyle)
    # file log
    if IS_ERROR_FILE:
      let path = logDir & "/error.log"
      createDir(parentDir(path))
      let logger = newRollingFileLogger(path, mode=fmAppend, fmtStr=verboseFmtStr)
      defer: logger.file.close()
      logger.log(lvlError, msg)
      flushFile(logger.file)
