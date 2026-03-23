import std/asyncdispatch
import std/json
import std/times
import std/strutils
import basolato/password
import allographer/query_builder
import faker
import ../schema


let fake = newFaker()


proc tagArticle*(rdb:PostgresConnections) {.async.} =
  let articles = rdb.table("article").get().orm(ArticleTable).await
  let articleCount = articles.len()
  let tags = rdb.table("tag").get().orm(TagTable).await
  let tagCount = tags.len()

  var tagArticles:seq[TagArticleMapTable]
  for i in 1..60:
    while true:
      let tagArticle = TagArticleMapTable(
        tag_id:tags[rand(1..tagCount-1)].id,
        article_id: articles[rand(1..articleCount-1)].id
      )

      if tagArticles.contains(tagArticle):
        continue

      tagArticles.add(tagArticle)
      break
  
  rdb.table("tag_article_map").insert(tagArticles).await
