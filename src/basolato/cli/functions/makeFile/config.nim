import os, strformat, terminal
import utils

proc makeConfig*():int =
  let targetPath = &"{getCurrentDir()}/config.nims"
  
  if isFileExists(targetPath): return 0
  
  let CONFIG = &"""
import os

# DB Connection
putEnv("db.driver", "sqlite")
putEnv("db.connection", "{getCurrentDir()}/db.sqlite3")
putEnv("db.user", "")
putEnv("db.password", "")
putEnv("db.database", "")

# Logging
putEnv("log.isDisplay", "true")
putEnv("log.isFile", "true")
putEnv("log.dir", "{getCurrentDir()}/logs")

# Session timeout
putEnv("session.time", "3600") # secounds
"""

  var f = open(targetPath, fmWrite)
  f.write(CONFIG)
  defer: f.close()

  var message = &"created {targetPath}"
  styledWriteLine(stdout, fgGreen, bgDefault, message, resetStyle)
  return 1