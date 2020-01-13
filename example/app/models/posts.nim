import json
import allographer/query_builder

type Post* = ref object
  db: RDB

proc newPost*(): Post =
  return Post(
    db: RDB().table("posts")
  )


proc getPosts*(this:Post): seq[JsonNode] =
  this.db
    .select("posts.id", "posts.title", "posts.text", "users.name as auther")
    .join("users", "users.id", "=", "posts.auther_id")
    .get()

proc getPost*(this:Post, id:int): JsonNode =
  this.db
    .select("posts.id", "posts.title", "posts.text", "users.name as auther")
    .join("users", "users.id", "=", "posts.auther_id")
    .find(id, key="posts.id")

proc updatePost*(this:Post, id:int, title:string, text:string) =
  this.db
    .where("id", "=", id)
    .update(%*{
      "title": title,
      "text": text
    })