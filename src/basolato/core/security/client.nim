import asyncdispatch, asynchttpserver, times, json, strutils
import ./session, ./session_db, ./cookie

type Client* = ref object
  session*: Session

proc newClient*(sessionId:string):Future[Client] {.async.} =
  ## use in constructor
  let session =
    if await checkSessionIdValid(sessionId):
      await newSession(sessionId)
    else:
      await newSession()
  await session.set("last_access", $getTime())
  return Client(session:session)

proc newClient*(request:Request):Future[Client] {.async.} =
  ## use in constructor
  let sessionId = newCookie(request).get("session_id")
  return await newClient(sessionId)

proc getToken*(self:Client):Future[string] {.async.} =
  return await self.session.getToken()

proc set*(self:Client, key, value:string) {.async.} =
  if self.session.isNil:
    self.session = await newSession()
  await self.session.set(key, value)

proc set*(self:Client, key:string, value:JsonNode) {.async.} =
  if self.session.isNil:
    self.session = await newSession()
  await self.session.set(key, value)

proc some*(self:Client, key:string):Future[bool] {.async.} =
  if self.isNil:
    return false
  elif self.session.isNil:
    return false
  else:
    return await self.session.some(key)

proc get*(self:Client, key:string):Future[string] {.async.} =
  if await self.some(key):
    return await self.session.get(key)
  else:
    return ""

proc delete*(self:Client, key:string) {.async.} =
  await self.session.delete(key)

proc destroy*(self:Client) {.async.} =
  await self.session.destroy()

proc login*(self:Client) {.async.} =
  await self.set("is_login", $true)

proc logout*(self:Client) {.async.} =
  await self.set("is_login", $false)

proc anonumousCreateSession*(self:Client, req:Request):Future[bool] {.async.} =
  ## Recreate session because session id from request is invalid
  let sessionId = newCookie(req).get("session_id")
  if not await checkSessionIdValid(sessionId):
    return true
  elif self.session.isNil or not await checkSessionIdValid(await self.getToken):
    self.session = await newSession()
    await self.set("is_login", "false")
    await self.set("last_access", $getTime())
    return true
  else:
    return false

proc isLogin*(self:Client):Future[bool] {.async.} =
  if await self.some("is_login"):
    return parseBool(await self.session.get("is_login"))
  else:
    return false

proc setFlash*(self:Client, key, value:string) {.async.} =
  let key = "flash_" & key
  await self.set(key, value)

proc setFlash*(self:Client, key:string, value:JsonNode) {.async.} =
  let key = "flash_" & key
  await self.set(key, value)

proc hasFlash*(self:Client, key:string):Future[bool] {.async.} =
  result = false
  let rows = await self.session.db.getRows()
  for k, v in rows.pairs:
    if k.contains("flash_" & key):
      result = true
      break

proc getFlash*(self:Client):Future[JsonNode] {.async.} =
  result = newJObject()
  let rows = await self.session.db.getRows()
  for key, val in rows.pairs:
    if key.contains("flash_"):
      var newKey = key
      newKey.delete(0, 5)
      result[newKey] = val
      await self.delete(key)

proc getErrors(self:Client):Future[JsonNode] {.async.} =
  result = newJObject()
  let rows = await self.session.db.getRows()
  for key, val in rows.pairs:
    if key == "flash_errors":
      await self.delete(key)
      return val

proc getParams(self:Client):Future[JsonNode] {.async.} =
  result = newJObject()
  let rows = await self.session.db.getRows()
  for key, val in rows.pairs:
    if key == "flash_params":
      await self.delete(key)
      return val

proc getValidationResult*(self:Client):Future[tuple[params:JsonNode, errors:JsonNode]] {.async.} =
  return (await self.getParams(), await self.getErrors())