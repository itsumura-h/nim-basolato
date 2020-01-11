import os, parsecfg, terminal, logging

let logConfigFile = getCurrentDir() & "/config/logging.ini"

proc logger*(output: any, args:varargs[string]) =
  # get Config file
  {.gcsafe.}:
    let conf = loadConfig(logConfigFile)
  # console log
  let isDisplayString = conf.getSectionValue("Log", "display")
  if isDisplayString == "true":
    let logger = newConsoleLogger()
    logger.log(lvlInfo, $output & $args)
  # file log
  let isFileOutString = conf.getSectionValue("Log", "file")
  if isFileOutString == "true":
    # info $output & $args
    let path = conf.getSectionValue("Log", "logDir") & "/log.log"
    createDir(parentDir(path))
    let logger = newRollingFileLogger(path, mode=fmAppend, fmtStr=verboseFmtStr)
    logger.log(lvlInfo, $output & $args)
    flushFile(logger.file)


proc echoErrorMsg*(msg:string) =
  # console log
  styledWriteLine(stdout, fgRed, bgDefault, msg, resetStyle)
  # file log
  {.gcsafe.}:
    let conf = loadConfig(logConfigFile)
  let isFileOutString = conf.getSectionValue("Log", "file")
  if isFileOutString == "true":
    let path = conf.getSectionValue("Log", "logDir") & "/error.log"
    createDir(parentDir(path))
    let logger = newRollingFileLogger(path, mode=fmAppend, fmtStr=verboseFmtStr)
    logger.log(lvlError, msg)
    flushFile(logger.file)
