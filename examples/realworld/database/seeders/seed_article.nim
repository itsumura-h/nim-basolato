import std/asyncdispatch
import std/json
import std/times
import std/strutils
import std/strformat
import std/random
import allographer/query_builder
import ./lib/random_text
import ../../app/models/vo/article_id
import ../../app/models/vo/title
import ../schema

randomize()

type Article = object
  id: ArticleTable.id
  title: ArticleTable.title
  description: ArticleTable.description
  body: ArticleTable.body
  author_id: ArticleTable.author_id
  created_at: ArticleTable.created_at


proc article*(rdb:PostgresConnections) {.async.} =
  let users = rdb.table("user").get().orm(UserTable).await

  var articles:seq[Article]
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
    let article = Article(
      id: id.value,
      title: title.value,
      description: randomText(30),
      body: body,
      author_id: users[rand(0..<users.len)].id,
      created_at: now().utc().format("yyyy-MM-dd hh:mm:ss")
    )
    articles.add(article)
  
  rdb.table("article").insert(articles).await
