import std/os
import std/strutils
import allographer/connection

let testRdb* = dbopen(
  SQLite3, # SQLite3 or MySQL or MariaDB or PostgreSQL
  ":memory:",
  1,
  getEnv("DB_TIMEOUT").parseInt,
  getEnv("LOG_IS_DISPLAY").parseBool,
  getEnv("LOG_IS_FILE").parseBool,
  getEnv("LOG_DIR"),
)

let rdb* = dbopen(
  PostgreSQL, # SQLite3 or MySQL or MariaDB or PostgreSQL
  getEnv("DB_URL"),
  getEnv("DB_MAX_CONNECTION").parseInt,
  getEnv("DB_TIMEOUT").parseInt,
  getEnv("LOG_IS_DISPLAY").parseBool,
  getEnv("LOG_IS_FILE").parseBool,
  getEnv("LOG_DIR"),
)
