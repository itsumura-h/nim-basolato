Migration
===
[back](../../README.md)

Table of Contents

<!--ts-->
   * [Migration](#migration)
      * [Introduction](#introduction)
      * [Example](#example)

<!-- Added by: root, at: Sun Dec 27 18:21:25 UTC 2020 -->

<!--te-->

## Introduction
Use `ducere` command  
[`ducere make migration`](./ducere.md#migration)

```sh
ducere make migration createUsersTable
>> migrations/migration{datetime}createUsersTable.nim
```
and updated `/migrations/migrate.nim` automatically.

To run migration, run `migrate.nim`
```sh
nim c -r migrations/migrate
```

## Example
You have sample migration file.

mirations/migration0001.nim
```nim
import json, strformat
import allographer/schema_builder
import allographer/query_builder

proc migration0001*() =
  # Create table schema
  schema([
    table("sample_users", [
      Column().increments("id"),
      Column().string("name"),
      Column().string("email")
    ])
  ])

  # Seeder
  var users: seq[JsonNode]
  for i in 1..10:
    users.add(%*{
      "id": i,
      "name": &"user{i}",
      "email": &"user{i}@nim.com"
    })
  RDB().table("sample_users").insert(users)
```

migrations/migrate.nim
```nim
import migration0001

proc main() =
  migration0001()

main()
```
If you don't need to create `sample users` table, delete `migration0001()` from `migrations/migrate.nim`

More details of `Schema Builder` and `Query Builder` is in allographer documents.  
[Schema Builder](https://github.com/itsumura-h/nim-allographer/blob/master/documents/schema_builder.md)  
[Query Builder](https://github.com/itsumura-h/nim-allographer/blob/master/documents/query_builder.md)
