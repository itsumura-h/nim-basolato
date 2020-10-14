import logging, os, terminal
import ./baseEnv

proc logger*(output: any, args:varargs[string]) =
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
  # console log
  if IS_DISPLAY:
    when not defined(release):
      styledWriteLine(stdout, fgRed, bgDefault, msg, resetStyle)
  # file log
  if IS_FILE:
    let path = LOG_DIR & "/error.log"
    createDir(parentDir(path))
    let logger = newRollingFileLogger(path, mode=fmAppend, fmtStr=verboseFmtStr)
    defer: logger.file.close()
    logger.log(lvlError, msg)
    flushFile(logger.file)