import std/os
import std/strformat
import std/terminal
import ./utils


template createConfigCommon(baseDir, target, CONFIG:untyped) =
  block:
    let targetPath = baseDir / target
    if not isFileExists(targetPath):
      let f = open(targetPath, fmWrite)
      defer: f.close()
      f.write(CONFIG)

      let message = "Created " & targetPath
      styledWriteLine(stdout, fgGreen, bgDefault, message, resetStyle)


proc makeConfig*(baseDir = getCurrentDir()):int =
  createConfigCommon(baseDir, "config.nims"):
    &"""
import std/os

putEnv("DB_SQLITE", $true) # "true" or "false"
# putEnv("DB_POSTGRES", $true) # "true" or "false"
# putEnv("DB_MYSQL", $true) # "true" or "false"
# putEnv("DB_MARIADB", $true) # "true" or "false"
putEnv("SESSION_TYPE", "file") # "file" or "redis"
putEnv("USE_LIBSASS", $false) # "true" or "false"
"""

  createConfigCommon(baseDir, ".env"):
    &"""
SECRET_KEY="{randStr(100)}"
DB_URL="db.sqlite3"
"""

  createConfigCommon(baseDir, ".env.example"):
    &"""
SECRET_KEY=""
DB_URL="db.sqlite3"
"""
