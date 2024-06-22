Migration
===
[back](../../README.md)

Table of Contents

<!--ts-->
* [Migration](#migration)
   * [Introduction](#introduction)
   * [Example](#example)

<!-- Created by https://github.com/ekalinin/github-markdown-toc -->
<!-- Added by: root, at: Sat Jun 22 11:26:36 UTC 2024 -->

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

You can also use `ducere` command.
```sh
ducere migrate
```

## Example
mirations/migration20210410131239user.nim
```nim
import json, strformat
import allographer/schema_builder
import allographer/query_builder

proc migration20210410131239user*() =
  schema(
    table("auth", [
      Column().increments("id"),
      Column().string("auth")
    ], reset=true),
    table("users", [
      Column().increments("id"),
      Column().string("name"),
      Column().string("email"),
      Column().foreign("auth_id").reference("id").on("auth").onDelete(SET_NULL),
      Column().timestamps()
    ], reset=true)
  )

  rdb().table("auth").insert([
    %*{"id": 1, "auth": "admin"},
    %*{"id": 2, "auth": "user"},
  ])

  var users: seq[JsonNode]
  for i in 1..100:
    users.add(%*{
      "id": i,
      "name": &"user{i}",
      "email": &"user{i}@nim.com",
      "auth_id": if i mod 2 == 0: 1 else: 2
    })
  rdb().table("users").insert(users)

  echo rdb().table("users").get()

```

migrations/migrate.nim
```nim
import migration20210410131239user

proc main() =
  discard
  migration20210410131239user()

main()
```

More details of `Schema Builder` and `Query Builder` is in allographer documents.  
- [Schema Builder](https://github.com/itsumura-h/nim-allographer/blob/master/documents/schema_builder.md)
- [Query Builder](https://github.com/itsumura-h/nim-allographer/blob/master/documents/query_builder.md)
