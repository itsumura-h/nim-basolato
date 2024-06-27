import os, asyncdispatch, json
import ./session_db/session_db_interface
import ../settings

when SESSION_TYPE == "redis":
  import ./session_db/redis_session_db
else:
  import ./session_db/json_session_db

type SessionDb* = object
  impl:ISessionDb

proc new*(_:type SessionDb, sessionId=""):Future[SessionDb] {.async.} =
  ## create SessionDb
  ## 
  ## if sessionId is not exists, create new one
  let sessionDb =
    when SESSION_TYPE == "redis":
      RedisSessionDb.new(sessionId).await.toInterface()
    else:
      JsonSessionDb.new(sessionId).await.toInterface()
  return SessionDb(impl:sessionDb)

proc checkSessionIdValid*(_:type SessionDb, token=""):Future[bool] {.async.} =
  when SESSION_TYPE == "redis":
    return RedisSessionDb.checkSessionIdValid(token).await
  else:
    return JsonSessionDb.checkSessionIdValid(token).await

proc getToken*(self:SessionDb):Future[string] {.async.} =
  return self.impl.getToken().await

proc setStr*(self:SessionDb, key, value: string):Future[void] {.async.} =
  self.impl.setStr(key, value).await

proc setJson*(self:SessionDb, key:string, value: JsonNode):Future[void] {.async.} =
  self.impl.setJson(key, value).await

proc isSome*(self:SessionDb, key:string):Future[bool] {.async.} =
  let res = self.impl.isSome(key).await
  return res

proc getStr*(self:SessionDb, key:string):Future[string] {.async.} =
  return self.impl.getStr(key).await

proc getJson*(self:SessionDb, key:string):Future[JsonNode] {.async.} =
  return self.impl.getJson(key).await

proc getRows*(self:SessionDb):Future[JsonNode] {.async.} =
  return self.impl.getRows().await

proc delete*(self:SessionDb, key:string):Future[void] {.async.} =
  self.impl.delete(key).await

proc destroy*(self:SessionDb):Future[void] {.async.} =
  self.impl.destroy().await
