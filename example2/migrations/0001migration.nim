import allographer/SchemaBuilder

Schema().create([
  Table().create("sample_users", [
    Column().increments("id"),
    Column().string("name"),
    Column().string("email")
  ])
])
