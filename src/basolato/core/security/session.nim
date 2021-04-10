import asyncdispatch, json
import session_db

type Session* = ref object
  db: SessionDb

proc newSession*(token=""):Future[Session] {.async.} =
  return Session(db:await newSessionDb(token))

proc db*(self:Session):SessionDb =
  return self.db

proc getToken*(self:Session):Future[string] {.async.} =
  return await self.db.getToken()

proc set*(self:Session, key, value:string) {.async.} =
  await self.db.set(key, value)

proc set*(self:Session, key:string, value:JsonNode) {.async.} =
  await self.db.set(key, value)

proc some*(self:Session, key:string):Future[bool] {.async.} =
  return await self.db.some(key)

proc get*(self:Session, key:string):Future[string] {.async.} =
  return await self.db.get(key)

proc delete*(self:Session, key:string) {.async.} =
  await self.db.delete(key)

proc destroy*(self:Session) {.async.} =
  await self.db.destroy()
