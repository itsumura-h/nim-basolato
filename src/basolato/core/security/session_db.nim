import asynchttpserver, asyncdispatch, httpcore, json, strutils, times, random, strformat, os
import ../baseEnv, token, ../utils
import encrypt

when SESSION_TYPE == "redis":
  import redis
  # ========== Redis ====================
  type SessionDb* = ref object
    conn: AsyncRedis
    id: string

  let REDIS_IP = SESSION_DB_PATH.split(":")[0]
  let REDIS_PORT = SESSION_DB_PATH.split(":")[1].parseInt

  proc new*(_:type SessionDb, sessionId=""):Future[SessionDb] {.async.} =
    let id =
      if sessionId.len == 0:
        randStr(256)
      else:
        sessionId

    let conn = await openAsync(REDIS_IP, Port(REDIS_PORT))
    discard await conn.hSet(id, "last_access", $getTime())
    discard await conn.expire(id, SESSION_TIME * 60)

    return SessionDb(
      conn: conn,
      id:id
    )

  proc checkSessionIdValid*(sessionId:string):Future[bool] {.async.} =
    let conn = await openAsync(REDIS_IP, Port(REDIS_PORT))
    if await conn.hExists(sessionId, "last_access"):
      return true
    else:
      return false

  proc getToken*(self:SessionDb):Future[string] {.async.} =
    return self.id

  proc set*(self:SessionDb, key, value: string) {.async.} =
    discard await self.conn.hSet(self.id, key, value)

  proc set*(self:SessionDb, key:string, value: JsonNode) {.async.} =
    discard await self.conn.hSet(self.id, key, $value)

  proc some*(self:SessionDb, key:string):Future[bool] {.async.} =
    return await self.conn.hExists(self.id, key)

  proc get*(self:SessionDb, key:string):Future[string] {.async.} =
    return await self.conn.hGet(self.id, key)

  proc getRows*(self:SessionDb):Future[JsonNode] {.async.} =
    let rows = await self.conn.hGetAll(self.id)
    # list to JsonNode
    var str = "{"
    for i, val in rows:
      if i == 0 or i mod 2 == 0:
        str.add(&"\"{val}\":")
      elif rows.len-1 != i:
        if val.contains("{") or val.contains("["):
          str.add(&"{val}, ")
        else:
          str.add(&"\"{val}\", ")
      else:
        if val.contains("{") or val.contains("["):
          str.add(&"{val}")
        else:
          str.add(&"\"{val}\"")
    str.add("}")
    return str.parseJson

  proc delete*(self:SessionDb, key:string) {.async.} =
    discard await self.conn.hDel(self.id, key)

  proc destroy*(self:SessionDb) {.async.} =
    discard await self.conn.del(@[self.id])

else:
  import flatdb
  # ========= Flat DB ==================
  type SessionDb* = ref object
    conn: FlatDb
    id: string
    sessionId: string

  proc clean(self:SessionDb) {.async.} =
    var buffer = newSeq[string]()
    for line in SESSION_DB_PATH.lines:
      if line.len == 0: break
      let lineJson = line.parseJson()
      if lineJson.hasKey("last_access"):
        let lastAccess = lineJson["last_access"].getStr().parse("yyyy-MM-dd\'T\'HH:mm:sszzz")
        let expireAt = lastAccess + SESSION_TIME.minutes
        if now() <= expireAt:
          buffer.add(line)
    if buffer.len > 0:
      buffer.add("")
      writeFile(SESSION_DB_PATH, buffer.join("\n"))

  proc isTokenValid(db:FlatDb, token:string):Future[bool] {.async.} =
    return db.query(equal("session_id", token)).len > 0

  proc createParentFlatDbDir():Future[FlatDb] {.async.} =
    if not dirExists(SESSION_DB_PATH.parentDir()):
      createDir(SESSION_DB_PATH.parentDir())
    return newFlatDb(SESSION_DB_PATH, false)

  proc new*(_:type SessionDb, sessionId=""):Future[SessionDb] {.async.} =
    let db = await createParentFlatDbDir()
    defer: db.close()
    var sessionDb: SessionDb
    # clean expired session probability of 1/100
    if rand(1..100) == 1:
      await sessionDb.clean()
    discard db.load()
    var sessionId = sessionId
    var id = ""
    if await db.isTokenValid(sessionId):
      id = db.queryOne(equal("session_id", sessionId))["_id"].getStr
    else:
      sessionId = randStr(256)
      id = db.append(%*{"session_id": sessionId})
    sessionDb = SessionDb(conn: db, id:id, sessionId:sessionId)
    return sessionDb

  proc checkSessionIdValid*(sessionId=""):Future[bool] {.async.} =
    let db = await createParentFlatDbDir()
    defer: db.close()
    discard db.load()
    return await db.isTokenValid(sessionId)

  proc getToken*(self:SessionDb):Future[string] {.async.} =
    return self.sessionId

  proc set*(self:SessionDb, key, value:string) {.async.} =
    let db = self.conn
    defer: db.close()
    db[self.id][key] = %value
    db.flush()

  proc set*(self:SessionDb, key:string, value:JsonNode) {.async.} =
    let db = self.conn
    defer: db.close()
    db[self.id][key] = value
    db.flush()

  proc some*(self:SessionDb, key:string):Future[bool] {.async.} =
    try:
      let db = self.conn
      defer: db.close()
      if db[self.id]{key}.isNil():
        return false
      else:
        return true
    except:
      return false

  proc get*(self:SessionDb, key:string):Future[string] {.async.} =
    let db = self.conn
    defer: db.close()
    return db[self.id]{key}.getStr("")

  proc getRows*(self:SessionDb):Future[JsonNode] {.async.} =
    return %*(self.conn[self.sessionId])

  proc delete*(self:SessionDb, key:string) {.async.} =
    let db = self.conn
    defer: db.close()
    let row = db[self.id]
    if row.hasKey(key):
      row.delete(key)
      db.flush()

  proc destroy*(self:SessionDb) {.async.} =
    self.conn.delete(self.id)
    defer: self.conn.close()
