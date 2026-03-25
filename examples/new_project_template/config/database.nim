import std/strutils
import allographer/connection


let rdb* = dbOpen(
  Sqlite3, # SQLite3 or MySQL or MariaDB or PostgreSQL or SurrealDB
  "db.sqlite3",
  maxConnections = 1,
  timeout = 30,
  shouldDisplayLog = true,
)
