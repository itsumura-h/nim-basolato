import std/asyncdispatch
import std/json
import std/os
import std/strutils
import std/times
import ../../baseEnv
import ../random_string
import ./libs/json_file_db
import ./session_db_interface


var globalCsrfToken*:string

type JsonSessionDb* = object
  db:JsonFileDb


proc new*(_:type JsonSessionDb, sessionId=""):Future[JsonSessionDb] {.async.} =
  ## create JsonSessionDb
  ## 
  ## if sessionId is not exists, create new one
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


proc updateCsrfToken(self:JsonSessionDb):Future[string] {.async.} =
  let csrfToken = randStr(100)
  self.setStr("csrf_token", csrfToken).await
  return csrfToken


proc toInterface*(self:JsonSessionDb):ISessionDb =
  return (
    getToken: proc():Future[string] {.async.} = return self.getToken().await,
    setStr: proc(key, value: string):Future[void] {.async.} = self.setStr(key, value).await,
    setJson: proc(key:string, value: JsonNode):Future[void] {.async.} = self.setJson(key, value).await,
    isSome: proc(key:string):Future[bool] {.async.} = return self.isSome(key).await,
    getStr: proc(key:string):Future[string] {.async.} = return self.getStr(key).await,
    getJson: proc(key:string):Future[JsonNode] {.async.} = return self.getJson(key).await,
    getRows: proc():Future[JsonNode] {.async.} = return self.getRows().await,
    delete: proc(key:string):Future[void] {.async.} = self.delete(key).await,
    destroy: proc():Future[void] {.async.} = self.destroy().await,
    updateCsrfToken: proc():Future[string] {.async.} = return self.updateCsrfToken().await
  )
