import std/os
import std/strutils
import basolato/settings
import allographer/connection


let rdb* = dbopen(
  Sqlite3, # SQLite3 or MySQL or MariaDB or PostgreSQL
  getEnv("DB_DATABASE"),
  getEnv("DB_USER"),
  getEnv("DB_PASSWORD"),
  getEnv("DB_HOST"),
  getEnv("DB_PORT").parseInt,
  getEnv("DB_MAX_CONNECTION").parseInt,
  getEnv("DB_TIMEOUT").parseInt,
  settings.settings.logToTerminal,
  settings.settings.logToFile,
  settings.settings.logDir,
)
