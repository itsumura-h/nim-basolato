import allographer/query_builder

let rdb* = dbopen(PostgreSQL,
  "hello_world",
  "benchmarkdbuser",
  "benchmarkdbpass",
  "tfb-database-pg",
  5432,
  90,
  3
)
