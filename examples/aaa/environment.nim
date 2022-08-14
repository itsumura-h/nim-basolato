import
  std/asyncdispatch,
  std/random,
  std/json,
  allographer/connection,
  allographer/schema_builder,
  allographer/query_builder

# let AppEnv* = getEnv("APP_ENV")
proc initDb*():Rdb =
  return dbOpen(PostgreSQL, "hello_world", "benchmarkdbuser", "benchmarkdbpass", "tfb-database-pg", 5432, 10, 30, true, false)


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
`=destroy`(rdb)
