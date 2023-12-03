import std/asyncdispatch
import std/json
import std/options
import ./session_db
import ./cookie
when defined(httpbeast) or defined(httpx):
  import ../libservers/nostd/request
else:
  import ../libservers/std/request


type Session* = ref object
  db: SessionDb

proc genNewSession*(token=""):Future[Session] {.async.} =
  let db = SessionDb.new(token).await
  let session = Session(db:db)
  return session

proc new*(typ:type Session, request:Request):Future[Session] {.async.} =
  let sessionId = Cookies.new(request).get("session_id")
  if SessionDb.checkSessionIdValid(sessionId).await:
    let session = genNewSession(sessionId).await
    return session
  else:
    let session = genNewSession().await
    return session

proc db*(self:Session):SessionDb =
  return self.db

proc getToken*(self:Session):Future[string] {.async.} =
  return await self.db.getToken()

proc updateNonce*(self:Session) {.async.} =
  await self.db.updateNonce()

proc set*(self:Session, key, value:string) {.async.} =
  await self.db.setStr(key, value)

proc set*(self:Session, key:string, value:JsonNode) {.async.} =
  self.db.setJson(key, value).await

proc isSome*(self:Session, key:string):Future[bool] {.async.} =
  return self.db.isSome(key).await

proc get*(self:Session, key:string):Future[string] {.async.} =
  return self.db.getStr(key).await

proc delete*(self:Session, key:string) {.async.} =
  self.db.delete(key).await

proc destroy*(self:Session) {.async.} =
  self.db.destroy().await

# ==================== utils ====================
# proc login*(self:)
