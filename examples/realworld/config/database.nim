import std/os
import std/strutils
import allographer/connection

let testRdb* = dbopen(
  SQLite3, # SQLite3 or MySQL or MariaDB or PostgreSQL
  ":memory:",
  maxConnections = 1,
  timeout = 30,
  shouldDisplayLog = true,
  shouldOutputLogFile = false,
)

let rdb* = dbopen(
  PostgreSQL, # SQLite3 or MySQL or MariaDB or PostgreSQL
  getEnv("DB_URL"),
  maxConnections = 95,
  timeout = 30,
  shouldDisplayLog = true,
  shouldOutputLogFile = false,
  logDir = "./logs",
)
