import os, strformat, terminal
import utils

proc makeConfig*():int =
  let targetPath = &"{getCurrentDir()}/config.nims"
  
  if isFileExists(targetPath): return 0
  
  let CONFIG = &"""
import os

# DB Connection
putEnv("DB_DRIVER", "sqlite")
putEnv("DB_CONNECTION", "{getCurrentDir()}/db.sqlite3")
putEnv("DB_USER", "")
putEnv("DB_PASSWORD", "")
putEnv("DB_DATABASE", "")

# Logging
putEnv("LOG_IS_DISPLAY", "true")
putEnv("LOG_IS_FILE", "true")
putEnv("LOG_DIR", "{getCurrentDir()}/logs")

# Session timeout
putEnv("SESSION_TIME", "3600") # secounds
"""

  var f = open(targetPath, fmWrite)
  f.write(CONFIG)
  defer: f.close()

  var message = &"created {targetPath}"
  styledWriteLine(stdout, fgGreen, bgDefault, message, resetStyle)
  return 1