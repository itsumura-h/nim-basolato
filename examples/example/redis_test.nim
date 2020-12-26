# import asyncdispatch
# import ../../src/basolato/core/security

# proc main() {.async.} =
#   let db = await newSessionDb()
#   echo db.repr

# waitFor main()

import asyncdispatch, redis, strformat
import ../../src/basolato/core/security

proc main() {.async.} =
  let db = await openAsync("redis")
  # let token = newToken("").getToken()
  let token = "755A3E93F74ED89EE9AF05A860AF2824585C6EE5EC35A2B67B05"
  echo token
  discard await db.hSet(token, "message", "Hello, World")
  discard await db.hSet(token, "key", "val")
  echo await db.hGet(&"{token}", "message")
  echo await db.hGetAll(token)

waitFor main()
