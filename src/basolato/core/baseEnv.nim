import os, strutils

const
  # Security
  SECRET_KEY*       = getEnv("SECRET_KEY").string
  # Logging
  IS_DISPLAY*       = getEnv("LOG_IS_DISPLAY").string.parseBool
  IS_FILE*          = getEnv("LOG_IS_FILE").string.parseBool
  IS_ERROR_FILE*    = getEnv("LOG_IS_ERROR_FILE").string.parseBool
  LOG_DIR*          = getEnv("LOG_DIR").string
  # Session db
  SESSION_TYPE*     = getEnv("SESSION_TYPE").string
  SESSION_DB_PATH*  = getEnv("SESSION_DB_PATH").string
  REDIS_PORT*       = getEnv("REDIS_PORT").string.parseInt
  SESSION_TIME*     = getEnv("SESSION_TIME").string.parseInt
  COOKIE_DOMAINS*    = getEnv("COOKIE_DOMAINS").string
  # Run
  PORT_NUM*         = getEnv("port").string.parseInt
