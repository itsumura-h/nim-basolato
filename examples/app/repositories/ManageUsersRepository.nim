import json
import allographer/query_builder

proc index*(): seq[JsonNode] =
  return RDB().table("users").get()


proc show*(id: int): JsonNode =
  return RDB().table("users").find(id)
