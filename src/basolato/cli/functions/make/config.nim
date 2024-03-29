import std/os
import std/strformat
import std/terminal
import ./utils


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
import std/os
putEnv("HOST", "0.0.0.0")
putEnv("DB_SQLITE", $true) # "true" or "false"
# putEnv("DB_POSTGRES", $true) # "true" or "false"
# putEnv("DB_MYSQL", $true) # "true" or "false"
# putEnv("DB_MARIADB", $true) # "true" or "false"
putEnv("SESSION_TYPE", "file") # "file" or "redis"
putEnv("SESSION_DB_PATH", "./session.db") # Session file path or redis host:port. ex:"127.0.0.1:6379"
putEnv("LIBSASS", $false) # "true" or "false"
"""

  createConfigCommon ".env":
    &"""
# Secret
SECRET_KEY="{randStr(100)}"

# DB Connection
DB_DATABASE="{getCurrentDir()}/db.sqlite3" # sqlite file path or database name
DB_USER=""
DB_PASSWORD=""
DB_HOST=""  # host ip address
DB_PORT=0 # postgres default...5432, mysql default...3306
DB_MAX_CONNECTION=95 # should be smaller than (DB max connection / running num processes)
DB_TIMEOUT=30 # secounds

# Logging
LOG_IS_DISPLAY=true # true or false
LOG_IS_FILE=true # true or false
LOG_IS_ERROR_FILE=true # true or false
LOG_DIR="{getCurrentDir()}/logs"

# Session db
# Session type, file or redis, is defined in config.nims
SESSION_TIME=120 # minutes of 2 hours
SESSION_EXPIRE_ON_CLOSE=false # If you want remove session immediately expire on the browser closing, set true
COOKIE_DOMAINS="" # to specify multiple domains, "sample.com, sample.org"

LOCALE=en
"""

  createConfigCommon ".env.example":
    &"""
# Secret
SECRET_KEY=""

# DB Connection
DB_DATABASE="{getCurrentDir()}/db.sqlite3" # sqlite file path or database name
DB_USER=""
DB_PASSWORD=""
DB_HOST=""  # host ip address
DB_PORT=0 # postgres default...5432, mysql default...3306
DB_MAX_CONNECTION=95 # should be smaller than (DB max connection / running num processes)
DB_TIMEOUT=30 # secounds

# Logging
LOG_IS_DISPLAY=true # true or false
LOG_IS_FILE=true # true or false
LOG_IS_ERROR_FILE=true # true or false
LOG_DIR="{getCurrentDir()}/logs"

# Session db
# Session type, file or redis, is defined in config.nims
SESSION_DB_PATH="{getCurrentDir()}/session.db" # Session file path or redis host:port. ex:"127.0.0.1:6379"
SESSION_TIME=120 # minutes of 2 hours
SESSION_EXPIRE_ON_CLOSE=false # If you want remove session immediately expire on the browser closing, set true
COOKIE_DOMAINS="" # to specify multiple domains, "sample.com, sample.org"

LOCALE=en
"""
