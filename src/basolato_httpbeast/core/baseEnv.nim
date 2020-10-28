import os, strutils

const
  IS_DISPLAY* = getEnv("LOG_IS_DISPLAY").string.parseBool
  IS_FILE* = getEnv("LOG_IS_FILE").string.parseBool
  LOG_DIR* = getEnv("LOG_DIR").string
  SECRET_KEY* = getEnv("SECRET_KEY").string
  CSRF_TIME* = getEnv("CSRF_TIME").string.parseInt
  SESSION_TIME* = getEnv("SESSION_TIME").string
  SESSION_DB_PATH* = getEnv("SESSION_DB").string
  IS_SESSION_MEMORY* = getEnv("IS_SESSION_MEMORY").string.parseBool
