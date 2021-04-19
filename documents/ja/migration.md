マイグレーション
===
[戻る](../../README.md)

コンテンツ

<!--ts-->
   * [Migration](#migration)
      * [イントロダクション](#イントロダクション)
      * [サンプル](#サンプル)

<!-- Added by: root, at: Mon Apr 19 03:05:09 UTC 2021 -->

<!--te-->

## イントロダクション
マイグレーションファイルを作るには、`ducere`コマンドを使います。  
[`ducere make migration`](./ducere.md#migration)

```sh
ducere make migration createUsersTable
>> migrations/migration{datetime}createUsersTable.nim
```

コマンドを実行すると、`/migrations/migrate.nim`は自動的に更新されます。

マイグレーションを実行するには、`migrate.nim`を実行してください。
```sh
nim c -r migrations/migrate
```

ducereコマンドを使うこともできます
```sh
ducere migrate
```

## サンプル

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

「Schema Builder」と「Query Builder」の詳細については、allographerのドキュメントを参照してください。
[Schema Builder](https://github.com/itsumura-h/nim-allographer/blob/master/documents/schema_builder.md)  
[Query Builder](https://github.com/itsumura-h/nim-allographer/blob/master/documents/query_builder.md)
