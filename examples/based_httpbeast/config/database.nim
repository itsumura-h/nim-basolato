import
  std/asyncdispatch,
  std/json,
  std/random,
  allographer/connection,
  allographer/schema_builder,
  allographer/query_builder


randomize()

let rdb* = dbOpen(PostgreSQL, "database", "user", "pass", "postgreDb", 5432, 96, 30, false, false)

rdb.create(
  table("num_table", [
    Column.integer("id"),
    Column.integer("randomnumber")
  ])
)

seeder rdb, "num_table":
  var data = newSeq[JsonNode]()
  for i in 1..10000:
    let randomNum = rand(10000)
    data.add(%*{"id": i, "randomnumber": randomNum})
  rdb.table("num_table").insert(data).waitFor
