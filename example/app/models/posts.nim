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
    .select("posts.id", "posts.title", "posts.post", "users.name as user")
    .join("users", "users.id", "=", "posts.user_id")
    .get()

proc getPost*(this:Post, id:int): JsonNode =
  this.db
    .select("posts.id", "posts.title", "posts.post", "users.name as user")
    .join("users", "users.id", "=", "posts.user_id")
    .find(id, key="posts.id")

proc updatePost*(this:Post, id:int, title:string, post:string) =
  this.db
    .where("id", "=", id)
    .update(%*{
      "title": title,
      "post": post
    })