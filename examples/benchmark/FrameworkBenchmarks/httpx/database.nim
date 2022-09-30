import std/asyncdispatch
import std/json
import std/os
import std/strutils
import std/streams
import std/parsecfg
import std/random
import allographer/connection
import allographer/schema_builder
import allographer/query_builder


for f in walkDir(getCurrentDir()):
  if f.path.split("/")[^1] == ".env":
    let path = getCurrentDir() / ".env"
    var f = newFileStream(path, fmRead)
    echo("httpx uses config file '", path, "'")
    var p: CfgParser
    open(p, f, path)
    while true:
      var e = next(p)
      case e.kind
      of cfgEof: break
      of cfgKeyValuePair: putEnv(e.key, e.value)
      else: discard
    break

let rdb* = dbopen(
  PostgreSQL, # SQLite3 or MySQL or MariaDB or PostgreSQL
  getEnv("DB_DATABASE"),
  getEnv("DB_USER"),
  getEnv("DB_PASSWORD"),
  getEnv("DB_HOST"),
  getEnv("DB_PORT", "5432").parseInt,
  getEnv("DB_MAX_CONNECTION", "95").parseInt,
  getEnv("DB_TIMEOUT", "30").parseInt,
  getEnv("LOG_IS_DISPLAY", $true).parseBool,
  getEnv("LOG_IS_FILE", $false).parseBool,
  getEnv("LOG_DIR"),
)

let cacheDb* = dbopen(
  SQLite3, # SQLite3 or MySQL or MariaDB or PostgreSQL
  ":memory:",
  maxConnections = getEnv("DB_MAX_CONNECTION").parseInt,
  shouldDisplayLog = false
)

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
