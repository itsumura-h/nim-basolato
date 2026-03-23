import std/asyncdispatch
import allographer/query_builder
import allographer/schema_builder


proc createTable*(rdb:SqliteConnections) {.async.} =
  rdb.create(
    table("user",
      Column.increments("id"),
      Column.string("username"),
      Column.string("email").unique(),
      Column.datetime("email_verified_at").nullable(),
      Column.string("password"),
      Column.text("bio").nullable(),
      Column.text("image").nullable(),
      Column.timestamps(),
    ),
    table("article",
      Column.string("id").unique(),
      Column.string("title"),
      COlumn.text("description"),
      COlumn.text("body"),
      Column.foreign("author_id").reference("id").onTable("user").onDelete(CASCADE),
      Column.timestamps()
    ),
    table("comment",
      Column.increments("id"),
      COlumn.text("body"),
      Column.strForeign("article_id").reference("id").onTable("article").onDelete(CASCADE),
      Column.foreign("author_id").reference("id").onTable("user").onDelete(CASCADE),
      Column.timestamps()
    ),
    table("tag",
      Column.increments("id"),
      Column.string("tag_id").unique(),
    ),

    table("user_user_map",
      Column.foreign("user_id").reference("id").onTable("user").onDelete(CASCADE).index(),
      Column.foreign("follower_id").reference("id").onTable("user").onDelete(CASCADE).index(),
    ),
    table("user_article_map",
      Column.foreign("user_id").reference("id").onTable("user").onDelete(CASCADE),
      Column.strForeign("article_id").reference("id").onTable("article").onDelete(CASCADE).index(),
    ),
    table("tag_article_map",
      Column.foreign("tag_id").reference("id").onTable("tag").onDelete(CASCADE).index(),
      Column.strForeign("article_id").reference("id").onTable("article").onDelete(CASCADE).index(),
    )
  )
