import std/asyncdispatch
import std/json
import std/times
import std/strutils
import allographer/query_builder
import faker
import ../lib/random_text
import ../../schema

type Comment = object
  body: CommentTable.body
  article_id: CommentTable.article_id
  author_id: CommentTable.author_id
  created_at: CommentTable.created_at


proc comment*(rdb:PostgresConnections) {.async.} =
  let users = rdb.table("user").get().orm(UserTable).await
  let articles = rdb.table("article").get().orm(ArticleTable).await
  let articleCount = articles.len()
  var comments:seq[Comment]
  for i in 1..60:
    let randomArticleNum = rand(0..articleCount-1)
    let comment = Comment(
      body: randomText(150),
      article_id: articles[randomArticleNum].id,
      author_id: users[rand(0..<users.len)].id,
      created_at: now().utc().format("yyyy-MM-dd hh:mm:ss")
    )
    comments.add(comment)
  
  rdb.table("comment").insert(comments).await
