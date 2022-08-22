import
  std/asyncdispatch,
  std/random,
  std/json,
  allographer/connection,
  allographer/schema_builder,
  allographer/query_builder

proc initDb*():Rdb =
  return dbOpen(PostgreSQL, "hello_world", "benchmarkdbuser", "benchmarkdbpass", "tfb-database-pg", 5432, 20, 30, false, false)
  # return dbOpen(PostgreSQL, "db_name", "user", "pass", "db_host", 5432, 20, 30, true, false)

type Plugin* = ref object
  rdb*: Rdb

randomize()

var rdb = initDb()
rdb.create(
  table("World", [
    Column.integer("id"),
    Column.integer("randomnumber")
  ])
)

seeder rdb, "World":
  var data = newSeq[JsonNode]()
  for i in 1..10000:
    let randomNum = rand(10000)
    data.add(%*{"id": i, "randomnumber": randomNum})
  rdb.table("World").insert(data).waitFor
