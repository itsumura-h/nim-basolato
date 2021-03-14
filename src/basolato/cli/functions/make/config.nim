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
putEnv("DB_MAX_CONNECTION", $95) # should be smaller than (DB max connection / running threads num)

# Logging
putEnv("LOG_IS_DISPLAY", $true) # true or false
putEnv("LOG_IS_FILE", $true) # true or false
putEnv("LOG_IS_ERROR_FILE", $true) # true or false
putEnv("LOG_DIR", "/root/project/examples/test1/logs")

# Session db
putEnv("SESSION_TYPE", "file") # "file" or "redis"
putEnv("SESSION_DB_PATH", "/root/project/examples/test1/session.db") # Session file path or redis host:port
putEnv("SESSION_TIME", $20160) # minutes of 2 weeks
putEnv("ENABLE_ANONYMOUS_COOKIE", $true) # true or false
putEnv("COOKIE_DOMAINS", "") # to specify multiple domains, "sample.com, sample.org"
"""

  var f = open(targetPath, fmWrite)
  defer: f.close()
  f.write(CONFIG)

  var message = &"Created {targetPath}"
  styledWriteLine(stdout, fgGreen, bgDefault, message, resetStyle)
  return 0
