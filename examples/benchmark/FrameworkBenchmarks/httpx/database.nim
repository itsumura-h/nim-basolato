import std/asyncdispatch
import std/json
import std/random
import allographer/connection
import allographer/schema_builder
import allographer/query_builder


let rdb* = dbopen(
  PostgreSQL, # SQLite3 or MySQL or MariaDB or PostgreSQL
  "database",
  "user",
  "pass",
  "postgreDb",
  5432,
  95,
  30,
  true,
  false,
  "",
)

let cacheDb* = dbopen(
  SQLite3, # SQLite3 or MySQL or MariaDB or PostgreSQL
  ":memory:",
  maxConnections = 95,
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
