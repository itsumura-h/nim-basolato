import std/asyncdispatch
import std/httpcore
import std/json
import std/strutils
import std/times
import std/os
import redis
import ../../settings
import ../random_string
import ./session_db_interface


type RedisSessionDb* = object
  conn:AsyncRedis
  id: string

var redisConn: AsyncRedis = nil


proc parseSessionPath(): tuple[host: string, port: Port] =
  let sessionPath = SESSION_PATH.strip()
  let idx = sessionPath.rfind(':')
  if sessionPath.len == 0 or idx <= 0 or idx >= sessionPath.len - 1:
    raise newException(ValueError, "SESSION_PATH must be in host:port format when SESSION_TYPE=redis")

  let host = sessionPath[0..<idx].strip()
  let portStr = sessionPath[idx + 1 .. ^1].strip()
  if host.len == 0:
    raise newException(ValueError, "SESSION_PATH host is empty when SESSION_TYPE=redis")

  try:
    result = (host: host, port: Port(portStr.parseInt()))
  except ValueError:
    raise newException(ValueError, "SESSION_PATH port must be an integer: " & portStr)


proc getRedisConn(): Future[AsyncRedis] {.async.} =
  if redisConn.isNil:
    let sessionConfig = parseSessionPath()
    redisConn = openAsync(sessionConfig.host, sessionConfig.port).await
  else:
    try:
      discard await redisConn.ping()
    except Exception:
      redisConn = nil
      let sessionConfig = parseSessionPath()
      redisConn = openAsync(sessionConfig.host, sessionConfig.port).await
  return redisConn

proc checkSessionIdValid*(_:type RedisSessionDb, sessionId=""):Future[bool] {.async.} =
  let conn = await getRedisConn()
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
  let rows = self.conn.hGetAll(self.id).await
  result = newJObject()
  var i = 0
  while i < rows.len:
    let key = rows[i]
    let val = rows[i+1]
    if val.startsWith("{") or val.startsWith("["):
      try:
        result[key] = val.parseJson
      except Exception:
        result[key] = %val
    else:
      result[key] = %val
    i += 2


proc delete(self:RedisSessionDb, key:string):Future[void] {.async.} =
  discard self.conn.hDel(self.id, key).await


proc destroy(self:RedisSessionDb):Future[void] {.async.} =
  discard self.conn.del(@[self.id]).await


proc sessionExpireSeconds(): int =
  ## `SESSION_TIME == 0` は「無期限扱い」の互換として 1 年に寄せる。
  if SESSION_TIME > 0:
    return SESSION_TIME * 60
  return 60 * 60 * 24 * 365


proc new*(_:type RedisSessionDb, sessionId=""):Future[RedisSessionDb] {.async.} =
  let id =
    if sessionId.len == 0:
      secureRandStr(100)
    elif not RedisSessionDb.checkSessionIdValid(sessionId).await:
      secureRandStr(100)
    else:
      sessionId

  let conn = getRedisConn().await
  let sessionDb = RedisSessionDb(
    conn:conn,
    id:id,
  )
  sessionDb.setStr("session_id", id).await
  discard conn.expire(id, sessionExpireSeconds()).await
  return sessionDb


converter toInterface*(self:RedisSessionDb):ISessionDb =
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
  )
