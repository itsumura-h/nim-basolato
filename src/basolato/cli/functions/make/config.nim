import os, strformat, terminal
import utils


proc makeConfig*():int =
  let targetPath = &"{getCurrentDir()}/config.nims"

  if isFileExists(targetPath): return 0

  let CONFIG = &"""
import os

# Security
putEnv("SECRET_KEY", "{randStr(24)}") # 24 length

# DB Connection
putEnv("DB_DRIVER", "sqlite") # "sqlite" or "mysql" or "postgres"
putEnv("DB_CONNECTION", "{getCurrentDir()}/db.sqlite3") # sqlite file path or host:port
putEnv("DB_USER", "")
putEnv("DB_PASSWORD", "")
putEnv("DB_DATABASE", "")
putEnv("DB_MAX_CONNECTION", "95")

# Logging
putEnv("LOG_IS_DISPLAY", "true") # true or false
putEnv("LOG_IS_FILE", "true") # true or false
putEnv("LOG_IS_ERROR_FILE", "true") # true or false
putEnv("LOG_DIR", "{getCurrentDir()}/logs")

# Session db
putEnv("SESSION_TYPE", "file") # "file" or "redis"
putEnv("SESSION_DB_PATH", "{getCurrentDir()}/session.db") # Session file path or IP address or Docker service name
putEnv("SESSION_TIME", "20160") # minutes of 2 weeks
putEnv("REDIS_PORT", "6379")
putEnv("ENABLE_ANONYMOUS_COOKIE", "true") # true or false
putEnv("COOKIE_DOMAINS", "")
"""

  var f = open(targetPath, fmWrite)
  defer: f.close()
  f.write(CONFIG)

  var message = &"Created {targetPath}"
  styledWriteLine(stdout, fgGreen, bgDefault, message, resetStyle)
  return 0
