import os, strformat, terminal
import utils


template createConfigCommon(target, CONFIG:untyped) =
  block:
    let targetPath = getCurrentDir() / target
    if not isFileExists(targetPath):
      let f = open(targetPath, fmWrite)
      defer: f.close()
      f.write(CONFIG)

      let message = "Created " & targetPath
      styledWriteLine(stdout, fgGreen, bgDefault, message, resetStyle)


proc makeConfig*():int =
  createConfigCommon "config.nims":
    &"""
import os
putEnv("SECRET_KEY", "{randStr(24)}") # 24 chars
putEnv("SESSION_TYPE", "file") # "file" or "redis"
"""

  createConfigCommon ".env":
    &"""
# DB Connection
DB_DATABASE="{getCurrentDir()}/db.sqlite3" # sqlite file path or database name
DB_USER=""
DB_PASSWORD=""
DB_HOST=""  # host ip address
DB_PORT=0 # postgres default...5432, mysql default...3306
DB_MAX_CONNECTION=95 # should be smaller than (DB max connection / running threads num)
DB_TIMEOUT=30 # secounds

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

HOST="0.0.0.0"
LOCALE=en
"""

  copyFile(&"{getCurrentDir()}/.env", &"{getCurrentDir()}/.env.example")
