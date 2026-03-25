import allographer/connection

let rdb* = dbOpen(
  SQLite3, # SQLite3 or MySQL or MariaDB or PostgreSQL
  "db.sqlite3",
  maxConnections = 95,
  timeout = 30,
  shouldDisplayLog = true,
  shouldOutputLogFile = false,
  logDir = "./logs",
)

let pgDb* = dbopen(
  PostgreSQL, # SQLite3 or MySQL or MariaDB or PostgreSQL
  "postgres://database:user:pass@postgreDb:5432/database",
  maxConnections = 95,
  timeout = 30,
  shouldDisplayLog = true,
  shouldOutputLogFile = false,
  logDir = "./logs",
)
