import asynchttpserver, asyncdispatch, httpcore, json, strutils, times, random, strformat, os
import ../baseEnv, token
import encrypt

when SESSION_TYPE == "redis":
  import redis
  # ========== Redis ====================
  type SessionDb* = ref object
    conn: AsyncRedis
    token: string

  let REDIS_IP = SESSION_DB_PATH.split(":")[0]
  let REDIS_PORT = SESSION_DB_PATH.split(":")[1].parseInt

  proc new*(_:type SessionDb, sessionId=""):Future[SessionDb] {.async.} =
    let token =
      if sessionId.len == 0:
        Token.new().getToken()
      else:
        sessionId

    let conn = await openAsync(REDIS_IP, Port(REDIS_PORT))
    discard await conn.hSet(token, "last_access", $getTime())
    discard await conn.expire(token, SESSION_TIME * 60)

    return SessionDb(
      conn: conn,
      token: token
    )

  proc checkSessionIdValid*(sessionId:string):Future[bool] {.async.} =
    let conn = await openAsync(REDIS_IP, Port(REDIS_PORT))
    if await conn.hExists(sessionId, "last_access"):
      return true
    else:
      return false

  proc getToken*(self:SessionDb):Future[string] {.async.} =
    return self.token

  proc set*(self:SessionDb, key, value: string) {.async.} =
    discard await self.conn.hSet(self.token, key, value)

  proc set*(self:SessionDb, key:string, value: JsonNode) {.async.} =
    discard await self.conn.hSet(self.token, key, $value)

  proc some*(self:SessionDb, key:string):Future[bool] {.async.} =
    return await self.conn.hExists(self.token, key)

  proc get*(self:SessionDb, key:string):Future[string] {.async.} =
    return await self.conn.hGet(self.token, key)

  proc getRows*(self:SessionDb):Future[JsonNode] {.async.} =
    let rows = await self.conn.hGetAll(self.token)
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
    discard await self.conn.hDel(self.token, key)

  proc destroy*(self:SessionDb) {.async.} =
    discard await self.conn.del(@[self.token])

else:
  import flatdb
  # ========= Flat DB ==================
  type SessionDb* = ref object
    conn: FlatDb
    token: string

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
    return db.exists(token)

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
    var token = sessionId.decryptCtr()
    if not await db.isTokenValid(token):
      token = db.append(newJObject())
    sessionDb = SessionDb(conn: db, token:token)
    return sessionDb

  proc checkSessionIdValid*(sessionId=""):Future[bool] {.async.} =
    let db = await createParentFlatDbDir()
    defer: db.close()
    discard db.load()
    var token = sessionId.decryptCtr()
    return await db.isTokenValid(token)

  proc getToken*(self:SessionDb):Future[string] {.async.} =
    return self.token.encryptCtr()

  proc set*(self:SessionDb, key, value:string) {.async.} =
    let db = self.conn
    defer: db.close()
    db[self.token][key] = %value
    db.flush()

  proc set*(self:SessionDb, key:string, value:JsonNode) {.async.} =
    let db = self.conn
    defer: db.close()
    db[self.token][key] = value
    db.flush()

  proc some*(self:SessionDb, key:string):Future[bool] {.async.} =
    try:
      let db = self.conn
      defer: db.close()
      if db[self.token]{key}.isNil():
        return false
      else:
        return true
    except:
      return false

  proc get*(self:SessionDb, key:string):Future[string] {.async.} =
    let db = self.conn
    defer: db.close()
    return db[self.token]{key}.getStr("")

  proc getRows*(self:SessionDb):Future[JsonNode] {.async.} =
    return %*(self.conn[self.token])

  proc delete*(self:SessionDb, key:string) {.async.} =
    let db = self.conn
    defer: db.close()
    let row = db[self.token]
    if row.hasKey(key):
      row.delete(key)
      db.flush()

  proc destroy*(self:SessionDb) {.async.} =
    self.conn.delete(self.token)
    defer: self.conn.close()
