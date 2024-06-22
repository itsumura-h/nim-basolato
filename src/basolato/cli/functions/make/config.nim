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


let currentDir = getCurrentDir()

proc makeConfig*():int =
  createConfigCommon("config.nims"):
    &"""
import std/os

putEnv("DB_SQLITE", $true) # "true" or "false"
# putEnv("DB_POSTGRES", $true) # "true" or "false"
# putEnv("DB_MYSQL", $true) # "true" or "false"
# putEnv("DB_MARIADB", $true) # "true" or "false"
putEnv("SESSION_TYPE", "file") # "file" or "redis"
putEnv("LIBSASS", $false) # "true" or "false"
"""

  createConfigCommon(".env"):
    &"""
# Secret
SECRET_KEY="{randStr(100)}"

# DB Connection
DB_DATABASE="{currentDir}/db.sqlite3" # sqlite file path or database name
DB_USER=""
DB_PASSWORD=""
DB_HOST=""  # host ip address
DB_PORT=0 # postgres default...5432, mysql default...3306
DB_MAX_CONNECTION=95 # should be smaller than (DB max connection / running num processes)
DB_TIMEOUT=30 # secounds

# Session db
# Session type, file or redis, is defined in config.nims
SESSION_DB_PATH = "{currentDir}/session.db" # Session file path or redis host:port. ex:"127.0.0.1:6379"

COOKIE_DOMAINS="" # to specify multiple domains, "sample.com, sample.org"
"""

  createConfigCommon(".env.example"):
    &"""
# Secret
SECRET_KEY=""

# DB Connection
DB_DATABASE="" # sqlite file path or database name
DB_USER=""
DB_PASSWORD=""
DB_HOST=""  # host ip address
DB_PORT=0 # postgres default...5432, mysql default...3306
DB_MAX_CONNECTION=95 # should be smaller than (DB max connection / running num processes)
DB_TIMEOUT=30 # secounds

# Session db
# Session type, file or redis, is defined in config.nims
SESSION_DB_PATH="" # Session file path or redis host:port. ex:"127.0.0.1:6379"

COOKIE_DOMAINS="" # to specify multiple domains, "sample.com, sample.org"
"""
