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
putEnv("DB_MAX_CONNECTION", "95")
putEnv("DB_TIMEOUT", "2000")
# Logging
putEnv("LOG_IS_DISPLAY", "true")
putEnv("LOG_IS_FILE", "true")
putEnv("LOG_DIR", "{getCurrentDir()}/logs")
# Security
putEnv("SECRET_KEY", "{randStr(24)}") # 24 length
putEnv("CSRF_TIME", "525600") # minutes of 1 year
putEnv("SESSION_TIME", "20160") # minutes of 2 weeks
putEnv("SESSION_DB", "{getCurrentDir()}/session.db")
putEnv("IS_SESSION_MEMORY", "false")
"""

  var f = open(targetPath, fmWrite)
  defer: f.close()
  f.write(CONFIG)

  var message = &"created {targetPath}"
  styledWriteLine(stdout, fgGreen, bgDefault, message, resetStyle)
  return 0