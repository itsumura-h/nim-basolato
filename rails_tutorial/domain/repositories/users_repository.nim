import json
import allographer/query_builder

proc usersShowRepository*(id:int):JsonNode =
  return RDB().table("users").find(id)