import std/asyncdispatch
import std/os
import std/strutils
import std/json
import std/random
import allographer/connection
import allographer/schema_builder
import allographer/query_builder

let rdb* = dbopen(
  Sqlite3, # SQLite3 or MySQL or MariaDB or PostgreSQL
  getEnv("DB_DATABASE"),
  getEnv("DB_USER"),
  getEnv("DB_PASSWORD"),
  getEnv("DB_HOST"),
  getEnv("DB_PORT").parseInt,
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

# ========== cache ==========
let cacheDb* = dbopen(
  SQLite3, # SQLite3 or MySQL or MariaDB or PostgreSQL
  ":memory:",
  maxConnections = 100,
  shouldDisplayLog = false
)

block:
  # migrate cacheDb
  cacheDb.create(
    table("World", [
      Column.increments("id"),
      Column.integer("randomNumber").default(0)
    ])
  )

  # seed cacheDb
  randomize()
  var data = newSeq[JsonNode]()
  for i in 1..10000:
    let randomNum = rand(10000)
    data.add(%*{"id": i, "randomNumber": randomNum})
  cacheDb.table("World").insert(data).waitFor
