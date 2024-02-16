import std/asyncdispatch
import std/json
import std/options
import ./session_db
import ./cookie
when defined(httpbeast) or defined(httpx):
  import ../libservers/nostd/request
else:
  import ../libservers/std/request

var globalCsrfToken*:string

type Session* = ref object
  db: SessionDb


proc new*(typ:type Session, sessionId=""):Future[Option[Session]] {.async.} =
  ## create Session
  ## 
  ## if sessionId is not exists, create new one
  let sessionDb = SessionDb.new(sessionId).await
  let session = Session(db:sessionDb)
  return session.some()

proc db*(self:Session):SessionDb =
  return self.db

proc getToken*(self:Option[Session]):Future[string] {.async.} =
  if self.isSome:
    return await self.get.db.getToken()
  else:
    return ""

proc updateCsrfToken*(self:Option[Session]) {.async.} =
  if self.isSome:
    let csrfToken = self.get.db.updateCsrfToken().await
    globalCsrfToken = csrfToken

proc set*(self:Option[Session], key, value:string) {.async.} =
  if self.isSome:
    await self.get.db.setStr(key, value)

proc set*(self:Option[Session], key:string, value:JsonNode) {.async.} =
  if self.isSome:
    self.get.db.setJson(key, value).await

proc isSome*(self:Option[Session], key:string):Future[bool] {.async.} =
  return self.isSome and self.get.db.isSome(key).await

proc get*(self:Option[Session], key:string):Future[string] {.async.} =
  if await self.isSome(key):
    return self.get.db.getStr(key).await
  else:
    return ""

proc delete*(self:Option[Session], key:string) {.async.} =
  if self.isSome:
    self.get.db.delete(key).await

proc destroy*(self:Option[Session]) {.async.} =
  if self.isSome:
    self.get.db.destroy().await
