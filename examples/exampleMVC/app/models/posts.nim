import json, times
# 3rd party
import allographer/query_builder

# DI
type Post* = ref object
  db: RDB

# constructor
proc newPost*(): Post =
  return Post(
    db: RDB().table("posts")
  )


proc getPosts*(this:Post): seq[JsonNode] =
  this.db
    .select(
      "posts.id",
      "title",
      "text",
      "name as auther",
      "published_date"
    )
    .join("users", "users.id", "=", "posts.auther_id")
    .where("published_date", "!=", "")
    .where("published_date", "<=", now().format("yyyy-MM-dd"))
    .orderBy("published_date", Desc)
    .orderBy("posts.id", Desc)
    .get()

proc getPost*(this:Post, id:int): JsonNode =
  this.db
    .select("id", "title", "text", "published_date", "auther_id")
    .find(id)

proc store*(this:Post, title:string, text:string, publishedDate:string, autherId:string): int =
  this.db
    .insertId(%*{
      "title": title,
      "text": text,
      "published_date": publishedDate,
      "auther_id": autherId
    })

proc updatePost*(this:Post, id:int, title:string, text:string) =
  this.db
    .where("id", "=", id)
    .update(%*{
      "title": title,
      "text": text
    })

proc deletePost*(this:Post, id:int) =
  this.db
    .delete(id)
