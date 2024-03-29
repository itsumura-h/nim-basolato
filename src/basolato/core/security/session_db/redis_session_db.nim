import std/asyncdispatch
import std/httpcore
import std/json
import std/strutils
import std/times
import std/os
import std/strformat
import redis
import ../../baseEnv
import ../random_string
import ./session_db_interface


type RedisSessionDb* = object
  conn: AsyncRedis
  id: string

let REDIS_IP = SESSION_DB_PATH.split(":")[0]
let REDIS_PORT = SESSION_DB_PATH.split(":")[1].parseInt


proc checkSessionIdValid*(_:type RedisSessionDb, sessionId=""):Future[bool] {.async.} =
  let conn = openAsync(REDIS_IP, Port(REDIS_PORT)).await
  if conn.exists(sessionId).await:
    return true
  else:
    return false

# implements RedisSessionDb, ISessionDb:
proc getToken(self:RedisSessionDb):Future[string] {.async.} =
  return self.id

proc setStr(self:RedisSessionDb, key:string, value: string):Future[void] {.async.} =
  discard self.conn.hSet(self.id, key, value).await

proc setJson(self:RedisSessionDb, key:string, value: JsonNode):Future[void] {.async.} =
  discard self.conn.hSet(self.id, key, $value).await

proc isSome(self:RedisSessionDb, key:string):Future[bool] {.async.} =
  return self.conn.hExists(self.id, key).await

proc getStr(self:RedisSessionDb, key:string):Future[string] {.async.} =
  return self.conn.hGet(self.id, key).await

proc getJson(self:RedisSessionDb, key:string):Future[JsonNode] {.async.} =
  return self.conn.hGet(self.id, key).await.parseJson()

proc getRows(self:RedisSessionDb):Future[JsonNode] {.async.} =
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

proc delete(self:RedisSessionDb, key:string):Future[void] {.async.} =
  discard await self.conn.hDel(self.id, key)

proc destroy(self:RedisSessionDb):Future[void] {.async.} =
  discard await self.conn.del(@[self.id])

proc updateCsrfToken(self:RedisSessionDb):Future[string] {.async.} =
  let csrfToken = randStr(100)
  self.setStr("csrf_token", csrfToken).await
  return csrfToken


proc new*(_:type RedisSessionDb, sessionId=""):Future[RedisSessionDb] {.async.} =
  let id =
    if sessionId.len == 0:
      secureRandStr(256)
    elif not RedisSessionDb.checkSessionIdValid(sessionId).await:
      secureRandStr(256)
    else:
      sessionId

  let conn = openAsync(REDIS_IP, Port(REDIS_PORT)).await

  let sessionDb = RedisSessionDb(
    conn: conn,
    id:id,
  )
  sessionDb.setStr("session_id", id).await
  discard sessionDb.conn.expire(id, SESSION_TIME * 60).await
  return sessionDb


proc toInterface*(self:RedisSessionDb):ISessionDb =
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
