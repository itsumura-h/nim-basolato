import json
import allographer/query_builder

type Auth* = ref object
  db: RDB

proc newAuth*(): Auth =
  return Auth(
    db: RDB().table("auth")
  )


proc getAuth*(this:Auth): seq[JsonNode] =
  return this.db.get()
