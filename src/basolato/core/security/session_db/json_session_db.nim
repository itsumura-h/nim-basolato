import std/asyncdispatch
import std/asyncfile
import std/json
import std/oids
import std/os
import std/strutils
import ../../baseEnv
import ../random_string
import ./libs/json_file_db
import ./session_db_interface


var globalNonce*:string

type JsonSessionDb* = ref object
  db:JsonFileDb

proc new*(_:type JsonSessionDb):Future[JsonSessionDb] {.async.} =
  if not dirExists(SESSION_DB_PATH.parentDir()):
    createDir(SESSION_DB_PATH.parentDir())

  let db = JsonFileDb.new().await
  let sessionId = secureRandStr(256)
  db.set("session_id", %sessionId)
  db.sync().await
  return JsonSessionDb(db:db)


proc new*(_:type JsonSessionDb, sessionId:string):Future[JsonSessionDb] {.async.} =
  if not dirExists(SESSION_DB_PATH.parentDir()):
    createDir(SESSION_DB_PATH.parentDir())

  let db = JsonFileDb.search("session_id", sessionId).await
  if not db.hasKey("session_id"):
    let sessionId = secureRandStr(256)
    db.set("session_id", %sessionId)
    db.sync().await
  return JsonSessionDb(db:db)


proc checkSessionIdValid*(_:type JsonSessionDb, token:string):Future[bool] {.async.} =
  return JsonFileDb.checkSessionIdValid("session_id", token).await


proc getToken(self:JsonSessionDb):Future[string] {.async.} =
  return self.db.get("session_id").getStr()


proc setStr(self:JsonSessionDb, key:string, value:string):Future[void] {.async.} =
  self.db.set(key, %value)
  self.db.sync().await


proc setJson(self:JsonSessionDb, key:string, value:JsonNode):Future[void] {.async.} =
  self.db.set(key, value)
  self.db.sync().await


proc isSome(self:JsonSessionDb, key:string):Future[bool] {.async.} =
  return self.db.hasKey(key)


proc getStr(self:JsonSessionDb, key:string):Future[string] {.async.} =
  return self.db.get(key).getStr()


proc getJson(self:JsonSessionDb, key:string):Future[JsonNode] {.async.} =
  return self.db.get(key)


proc getRows(self:JsonSessionDb):Future[JsonNode] {.async.} =
  return self.db.getRow()


proc delete(self:JsonSessionDb, key:string):Future[void] {.async.} =
  self.db.delete(key)
  self.db.sync().await


proc destroy(self:JsonSessionDb):Future[void] {.async.} =
  self.db.destroy().await


proc updateNonce(self:JsonSessionDb):Future[void] {.async.} =
  let nonce = randStr(100)
  globalNonce = nonce
  self.setStr("nonce", nonce).await


proc toInterface*(self:JsonSessionDb):ISessionDb =
  return (
    getToken: proc():Future[string] {.async.} = self.getToken().await,
    setStr: proc(key, value: string):Future[void] {.async.} = self.setStr(key, value).await,
    setJson: proc(key:string, value: JsonNode):Future[void] {.async.} = self.setJson(key, value).await,
    isSome: proc(key:string):Future[bool] {.async.} = self.isSome(key).await,
    getStr: proc(key:string):Future[string] {.async.} = self.getStr(key).await,
    getJson: proc(key:string):Future[JsonNode] {.async.} = self.getJson(key).await,
    getRows: proc():Future[JsonNode] {.async.} = self.getRows().await,
    delete: proc(key:string):Future[void] {.async.} = self.delete(key).await,
    destroy: proc():Future[void] {.async.} = self.destroy().await,
    updateNonce: proc():Future[void] {.async.} = self.updateNonce().await
  )
