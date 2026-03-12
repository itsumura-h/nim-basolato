import std/asyncdispatch
import allographer/query_builder
import allographer/schema_builder


proc createTable*(rdb:PostgresConnections) {.async.} =
  rdb.create(
    table("user", [
      Column.string("id").unique(), # username
      Column.string("name"),
      Column.string("email").unique(),
      Column.datetime("email_verified_at").nullable(),
      Column.string("password"),
      Column.text("bio").default(""),
      Column.text("image").default(""),
      Column.timestamps(),
    ]),
    table("article", [
      Column.string("id").unique(),
      Column.string("title").default(""),
      Column.text("description").default(""),
      Column.text("body").default(""),
      Column.strForeign("author_id").reference("id").onTable("user").onDelete(CASCADE),
      Column.timestamps()
    ]),
    table("comment", [
      Column.increments("id"),
      COlumn.text("body"),
      Column.strForeign("article_id").reference("id").onTable("article").onDelete(CASCADE),
      Column.strForeign("author_id").reference("id").onTable("user").onDelete(CASCADE),
      Column.timestamps()
    ]),
    table("tag", [
      Column.string("id").unique(),
      Column.string("name"),
    ]),

    table("user_user_map", [
      Column.strForeign("user_id").reference("id").onTable("user").onDelete(CASCADE).index(),
      Column.strForeign("follower_id").reference("id").onTable("user").onDelete(CASCADE).index(),
    ]),
    table("user_article_map", [
      Column.strForeign("user_id").reference("id").onTable("user").onDelete(CASCADE),
      Column.strForeign("article_id").reference("id").onTable("article").onDelete(CASCADE).index(),
    ]),
    table("tag_article_map", [
      Column.strForeign("tag_id").reference("id").onTable("tag").onDelete(CASCADE).index(),
      Column.strForeign("article_id").reference("id").onTable("article").onDelete(CASCADE).index(),
    ]),
  )
