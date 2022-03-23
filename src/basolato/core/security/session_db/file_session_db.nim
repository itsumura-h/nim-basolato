import
  asynchttpserver,
  asyncdispatch,
  httpcore,
  json,
  strutils,
  times,
  random,
  os
import redis, interface_implements
import ./session_db_interface
import ../random_string
import ../../baseEnv
import flatdb

var globalNonce*:string

type FileSessionDb* = ref object
  conn: FlatDb
  id: string
  sessionId: string

proc clean(self:FileSessionDb) {.async.} =
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

proc checkSessionIdValid*(_:type FileSessionDb, sessionId=""):Future[bool] {.async.} =
  let db = await createParentFlatDbDir()
  defer: db.close()
  discard db.load()
  return await db.isTokenValid(sessionId)

implements FileSessionDb, ISessionDb:
  proc getToken(self:FileSessionDb):Future[string] {.async.} =
    return self.sessionId

  proc setStr(self:FileSessionDb, key:string, value:string):Future[void] {.async.} =
    let db = self.conn
    defer: db.close()
    db[self.id][key] = %value
    db.flush()

  proc setJson(self:FileSessionDb, key:string, value:JsonNode):Future[void] {.async.} =
    let db = self.conn
    defer: db.close()
    db[self.id][key] = value
    db.flush()

  proc some(self:FileSessionDb, key:string):Future[bool] {.async.} =
    try:
      let db = self.conn
      defer: db.close()
      if db[self.id]{key}.isNil():
        return false
      else:
        return true
    except:
      return false

  proc get(self:FileSessionDb, key:string):Future[string] {.async.} =
    let db = self.conn
    defer: db.close()
    return db[self.id]{key}.getStr("")

  proc getRows(self:FileSessionDb):Future[JsonNode] {.async.} =
    return %*(self.conn[self.id])

  proc delete(self:FileSessionDb, key:string):Future[void] {.async.} =
    let db = self.conn
    defer: db.close()
    let row = db[self.id]
    if row.hasKey(key):
      row.delete(key)
      db.flush()

  proc destroy(self:FileSessionDb):Future[void] {.async.} =
    self.conn.delete(self.id)
    defer: self.conn.close()

  proc updateNonce(self:FileSessionDb):Future[void] {.async.} =
    let nonce = randStr(100)
    globalNonce = nonce
    await self.setStr("nonce", nonce)


proc new*(_:type FileSessionDb, sessionId:string):Future[FileSessionDb] {.async.} =
  let db = await createParentFlatDbDir()
  defer: db.close()
  var sessionDb: FileSessionDb
  # clean expired session probability of 1/100
  if rand(1..100) == 1:
    await sessionDb.clean()
  discard db.load()
  var sessionId = sessionId
  var id = ""
  if await db.isTokenValid(sessionId):
    id = db.queryOne(equal("session_id", sessionId))["_id"].getStr
  else:
    sessionId = secureRandStr(256)
    id = db.append(%*{"session_id": sessionId})
  sessionDb = FileSessionDb(
    conn: db,
    id:id,
    sessionId:sessionId
  )
  await sessionDb.setStr("last_access", $getTime())
  return sessionDb