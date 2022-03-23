import os, asyncdispatch, json
import ./session_db/session_db_interface
import ../baseEnv

when SESSION_TYPE == "redis":
  import ./session_db/redis_session_db
else:
  import ./session_db/file_session_db

export globalNonce


type SessionDb* = ref object
  impl:ISessionDb

proc new*(_:type SessionDb, token=""):Future[SessionDb] {.async.} =
  let sessionDb =
    when SESSION_TYPE == "redis":
      RedisSessionDb.new(token).await.toInterface()
    else:
      FileSessionDb.new(token).await.toInterface()
  return SessionDb(impl:sessionDb)

proc checkSessionIdValid*(_:type SessionDb, token=""):Future[bool] {.async.} =
  when SESSION_TYPE == "redis":
    return RedisSessionDb.checkSessionIdValid(token).await
  else:
    return FileSessionDb.checkSessionIdValid(token).await

proc getToken*(self:SessionDb):Future[string] {.async.} =
  return self.impl.getToken().await

proc setStr*(self:SessionDb, key, value: string):Future[void] {.async.} =
  self.impl.setStr(key, value).await

proc setJson*(self:SessionDb, key:string, value: JsonNode):Future[void] {.async.} =
  self.impl.setJson(key, value).await

proc some*(self:SessionDb, key:string):Future[bool] {.async.} =
  return self.impl.some(key).await

proc get*(self:SessionDb, key:string):Future[string] {.async.} =
  return self.impl.get(key).await

proc getRows*(self:SessionDb):Future[JsonNode] {.async.} =
  return self.impl.getRows().await

proc delete*(self:SessionDb, key:string):Future[void] {.async.} =
  self.impl.delete(key).await

proc destroy*(self:SessionDb):Future[void] {.async.} =
  self.impl.destroy().await

proc updateNonce*(self:SessionDb):Future[void] {.async.} =
  self.impl.updateNonce().await
