import asyncdispatch, json
import allographer/schema_builder
from ../../config/database import rdb


proc group_user_map*() {.async.} =
  rdb.create(
    table("group_user_map", [
      Column.strForeign("user_id").reference("id").onTable("users").onDelete(SET_NULL),
      Column.strForeign("group_id").reference("id").onTable("users").onDelete(SET_NULL),
      Column.boolean("is_admin").default(false)
    ])
  )
