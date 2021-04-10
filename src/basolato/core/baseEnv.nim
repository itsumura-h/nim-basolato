import os, strutils
import dotenv

const
  # Session db
  SESSION_TYPE* = getEnv("SESSION_TYPE", "file").string

let env = initDotEnv( getCurrentDir() )
env.load()

let
  # Security
  SECRET_KEY* = getEnv("SECRET_KEY").string
  # Logging
  IS_DISPLAY* = getEnv("LOG_IS_DISPLAY", $true).string.parseBool
  IS_FILE* = getEnv("LOG_IS_FILE", $true).string.parseBool
  IS_ERROR_FILE* = getEnv("LOG_IS_ERROR_FILE", $true).string.parseBool
  LOG_DIR* = getEnv("LOG_DIR").string
  # Session db
  # SESSION_TYPE* = getEnv("SESSION_TYPE", "file").string
  SESSION_DB_PATH* = getEnv("SESSION_DB_PATH").string
  SESSION_TIME* = getEnv("SESSION_TIME", "20160").string.parseInt
  COOKIE_DOMAINS* = getEnv("COOKIE_DOMAINS").string
  ENABLE_ANONYMOUS_COOKIE* = getEnv("ENABLE_ANONYMOUS_COOKIE").string.parseBool

  LANGUAGE* = getEnv("LANGUAGE", "en").string

  # Run
  PORT_NUM* = getEnv("port", "5000").string.parseInt
