import basolato/settings
import db_connector/db_postgres
import allographer/connection

when defined(release):
  import std/cpuinfo

let maxConnections =
  when defined(release):
    (2000 div countProcessors()) - 2
  else:
    95

let rdb* = dbopen(
  PostgreSQL, # SQLite3 or MySQL or MariaDB or PostgreSQL
  "database",
  "user",
  "pass",
  "postgreDb",
  5432,
  maxConnections,
  30,
  LOG_TO_CONSOLE,
  LOG_TO_FILE,
  LOG_DIR,
)

let stdRdb* = open("postgreDb", "user", "pass", "database")
