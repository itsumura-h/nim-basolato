import allographer/connection

let rdb* = dbOpen(
  Sqlite3, # SQLite3 or MySQL or MariaDB or PostgreSQL
  "",
  maxConnections = 498,
  timeout = 30,
  shouldDisplayLog = false,
  shouldOutputLogFile = false,
  logDir = "",
)
