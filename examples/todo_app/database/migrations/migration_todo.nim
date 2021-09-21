import asyncdispatch, json
import allographer/schema_builder
from ../../config/database import rdb


proc todo*() {.async.} =
  rdb.schema(
    table("todo", [
      Column().uuid("id"),
      Column().string("title"),
      Column().longText("content_md"),
      Column().longText("content_html"),
      Column().strForeign("created_by").reference("id").on("users").onDelete(SET_NULL).nullable(),
      Column().strForeign("assign_to").reference("id").on("users").onDelete(SET_NULL).nullable(),
      Column().datetime("start_on").default("0001-01-01"),
      Column().datetime("deadline").default("0001-01-01"),
      Column().foreign("status_id").reference("id").on("status").onDelete(RESTRICT).nullable(),
      Column().integer("sort").default(0)
    ])
  )
