import os, strutils
import dotenv

const
  SECRET_KEY* = getEnv("SECRET_KEY").string
  SESSION_TYPE* = getEnv("SESSION_TYPE").string
  PORT_NUM* = getEnv("PORT", "5000").string.parseInt

for f in walkDir(getCurrentDir()):
  if f.path.contains(".env"):
    let env = initDotEnv(getCurrentDir(), f.path.split("/")[^1])
    env.load()
    echo("used config file '", f.path, "'")

let
  # Logging
  IS_DISPLAY* = getEnv("LOG_IS_DISPLAY").string.parseBool
  IS_FILE* = getEnv("LOG_IS_FILE").string.parseBool
  IS_ERROR_FILE* = getEnv("LOG_IS_ERROR_FILE").string.parseBool
  LOG_DIR* = getEnv("LOG_DIR").string
  # Session db
  SESSION_DB_PATH* = getEnv("SESSION_DB_PATH").string
  SESSION_TIME* = getEnv("SESSION_TIME").string.parseInt
  COOKIE_DOMAINS* = getEnv("COOKIE_DOMAINS").string
  ENABLE_ANONYMOUS_COOKIE* = getEnv("ENABLE_ANONYMOUS_COOKIE").string.parseBool

  # others
  HOST_ADDR* = getEnv("HOST", "0.0.0.0").string
  LOCALE* = getEnv("LOCALE").string
