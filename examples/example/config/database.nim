import std/asyncdispatch
import std/os
import std/strutils
import std/json
import std/random
import allographer/connection
import allographer/schema_builder
import allographer/query_builder

let rdb* = dbOpen(
  SQLite3, # SQLite3 or MySQL or MariaDB or PostgreSQL
  getEnv("DB_DATABASE"),
  getEnv("DB_MAX_CONNECTION").parseInt,
  getEnv("DB_TIMEOUT").parseInt,
  getEnv("LOG_IS_DISPLAY").parseBool,
  getEnv("LOG_IS_FILE").parseBool,
  getEnv("LOG_DIR"),
)

let pgDb* = dbopen(
  PostgreSQL, # SQLite3 or MySQL or MariaDB or PostgreSQL
  "database",
  "user",
  "pass",
  "postgreDb",
  5432,
  getEnv("DB_MAX_CONNECTION").parseInt,
  getEnv("DB_TIMEOUT").parseInt,
  getEnv("LOG_IS_DISPLAY").parseBool,
  getEnv("LOG_IS_FILE").parseBool,
  getEnv("LOG_DIR"),
)
