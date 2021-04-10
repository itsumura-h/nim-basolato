import os, strformat, terminal
import utils


proc makeConfig*():int =
  var targetPath = &"{getCurrentDir()}/.env"
  if isFileExists(targetPath): return 0
  var CONFIG = &"""
# Security
SECRET_KEY="{randStr(24)}" # 24 length

# DB Connection
# DB type, sqlite or mysql or postgres, is defined in config.nims
DB_CONNECTION="{getCurrentDir()}/db.sqlite3" # sqlite file path or host:port
DB_USER=""
DB_PASSWORD=""
DB_DATABASE=""
DB_MAX_CONNECTION=95 # should be smaller than (DB max connection / running threads num)

# Logging
LOG_IS_DISPLAY=true # true or false
LOG_IS_FILE=true # true or false
LOG_IS_ERROR_FILE=true # true or false
LOG_DIR="{getCurrentDir()}/logs"

# Session db
# Session type, file or redis, is defined in config.nims
SESSION_DB_PATH="{getCurrentDir()}/session.db" # Session file path or redis host:port. ex:"127.0.0.1:6379"
SESSION_TIME=20160 # minutes of 2 weeks
ENABLE_ANONYMOUS_COOKIE=true # true or false
COOKIE_DOMAINS="" # to specify multiple domains, "sample.com, sample.org"
"""

  var f = open(targetPath, fmWrite)
  defer: f.close()
  f.write(CONFIG)

  var message = &"Created {targetPath}"
  styledWriteLine(stdout, fgGreen, bgDefault, message, resetStyle)

  targetPath = &"{getCurrentDir()}/config.nims"
  if isFileExists(targetPath): return 0
  CONFIG = &"""
import os
putEnv("DB_DRIVER", "sqlite") # "sqlite" or "mysql" or "postgres"
putEnv("SESSION_TYPE", "file") # "file" or "redis"
"""
  f = open(targetPath, fmWrite)
  f.write(CONFIG)

  message = &"Created {targetPath}"
  styledWriteLine(stdout, fgGreen, bgDefault, message, resetStyle)
  return 0
