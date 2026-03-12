import std/asyncdispatch
import std/json
import std/strutils
import allographer/query_builder
import faker
import ../schema


type Favorite = object
  user_id: UserTable.id
  article_id: ArticleTable.id


proc favorite*(rdb:PostgresConnections) {.async.} =
  let users = rdb.table("user").get().orm(UserTable).await
  let articles = rdb.table("article").get().orm(ArticleTable).await
  let articleCount = articles.len()
  
  var favorites:seq[Favorite]
  for i in 1..200:
    while true:
      let userId = users[rand(1..<users.len)].id
      let randomArticleNum = rand(0..articleCount-1)
      let articleId = articles[randomArticleNum].id

      var hasSame = false
      for favorite in favorites:
        if favorite.user_id == userId and favorite.article_id == articleId:
          hasSame = true
          break

      if hasSame:
        continue

      favorites.add(
        Favorite(
          user_id: userId,
          article_id: articleId,
        )
      )
      break
  
  rdb.table("user_article_map").insert(favorites).await
