import std/asyncdispatch
import std/json
import std/times
import std/strutils
import std/strformat
import std/random
import allographer/query_builder
import ../lib/random_text
import ../../schema
import ../../../app/models/vo/article_id
import ../../../app/models/vo/title

randomize()

proc article*(rdb:PostgresConnections) {.async.} =
  let users = rdb.table("user").get().orm(UserTable).await

  var articles:seq[ArticleTable]
  for i in 1..30:
    let title = Title.new( randomText(5) )
    let id = ArticleId.new()
    var body = fmt"""
# title
## subTitle1
- point1
  - point2
- point3

## subTitle2

```nim
proc fib(n: int): int =
  if n < 2:
    return n
  else:
    return fib(n - 1) + fib(n - 2)

echo(fib(30))
```

{randomText(500)}
"""
    let article = ArticleTable(
      id: id.value,
      title: title.value,
      description: randomText(30),
      body: body,
      author_id: users[rand(0..<users.len)].id,
      created_at: now().utc().format("yyyy-MM-dd hh:mm:ss"),
      updated_at: now().utc().format("yyyy-MM-dd hh:mm:ss")
    )
    articles.add(article)
  
  rdb.table("article").insert(articles).await
