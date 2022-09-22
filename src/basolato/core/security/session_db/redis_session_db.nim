import
  std/asyncdispatch,
  std/httpcore,
  std/json,
  std/strutils,
  std/times,
  std/os,
  std/strformat,
  redis,
  interface_implements,
  ./session_db_interface,
  ../random_string,
  ../../baseEnv


var globalNonce*:string

type RedisSessionDb* = ref object
  conn: AsyncRedis
  id: string

let REDIS_IP = SESSION_DB_PATH.split(":")[0]
let REDIS_PORT = SESSION_DB_PATH.split(":")[1].parseInt

proc new*(_:type RedisSessionDb, sessionId:string):Future[RedisSessionDb] {.async.} =
  let id =
    if sessionId.len == 0:
      secureRandStr(256)
    else:
      sessionId

  let conn = await openAsync(REDIS_IP, Port(REDIS_PORT))
  discard await conn.hSet(id, "last_access", $getTime())
  discard await conn.expire(id, SESSION_TIME * 60)

  return RedisSessionDb(
    conn: conn,
    id:id,
  )

proc checkSessionIdValid*(_:type RedisSessionDb, sessionId=""):Future[bool] {.async.} =
  let conn = await openAsync(REDIS_IP, Port(REDIS_PORT))
  if await conn.hExists(sessionId, "last_access"):
    return true
  else:
    return false

implements RedisSessionDb, ISessionDb:
  proc getToken(self:RedisSessionDb):Future[string] {.async.} =
    return self.id

  proc setStr(self:RedisSessionDb, key:string, value: string):Future[void] {.async.} =
    discard self.conn.hSet(self.id, key, value).await

  proc setJson(self:RedisSessionDb, key:string, value: JsonNode):Future[void] {.async.} =
    discard self.conn.hSet(self.id, key, $value).await

  proc some(self:RedisSessionDb, key:string):Future[bool] {.async.} =
    return await self.conn.hExists(self.id, key)

  proc get(self:RedisSessionDb, key:string):Future[string] {.async.} =
    return await self.conn.hGet(self.id, key)

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

  proc updateNonce(self:RedisSessionDb):Future[void] {.async.} =
    let nonce = randStr(100)
    globalNonce = nonce
    await self.setStr("nonce", nonce)
