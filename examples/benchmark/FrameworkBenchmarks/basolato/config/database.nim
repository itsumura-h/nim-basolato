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
  url="postgresql://benchmarkdbuser:benchmarkdbpass@tfb-database:5432/hello_world",
  maxConnections=maxConnections,
  timeout=30,
  shouldDisplayLog=false,
  shouldOutputLogFile=false,
  logDir="",
)
