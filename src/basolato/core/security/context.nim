import std/asyncdispatch 
import std/options
import std/strutils
import std/json
import ./session
import ./session_db

when defined(httpbeast) or defined(httpx):
  import ../libservers/nostd/request
else:
  import ../libservers/std/request


type Context* = ref object
  request: Request
  session: Option[Session]

proc new*(_:type Context, request:Request):Future[Context]{.async.} =
  return Context(
    request:request,
    session:none(Session)
  )

proc request*(self:Context):Request =
  return self.request

proc setSession*(self:Context, session:Session) =
  self.session = session.some()

proc session*(self:Context):Option[Session] =
  return self.session

proc getToken*(self:Context):Future[string]{.async.} =
  return await self.session.getToken()

proc updateNonce*(self:Context) {.async.} =
  await self.session.updateNonce()

proc login*(self:Context){.async.} =
  await self.session.set("is_login", $true)

proc logout*(self:Context){.async.} =
  await self.session.delete("is_login")

proc isLogin*(self:Context):Future[bool]{.async.} =
  if await self.session.isSome("is_login"):
    return parseBool(await self.session.get("is_login"))
  else:
    return false

proc isValid*(context:Context):Future[bool] {.async.} =
  ## Recreate session because session id from request is invalid.
  ##
  ## return true if new session is created
  let sessionId = await context.session.getToken()
  return SessionDb.checkSessionIdValid(sessionId).await

proc set*(self:Context, key, value:string) {.async.} =
  await self.session.set(key, value)

proc set*(self:Context, key:string, value:JsonNode) {.async.} =
  await self.session.set(key, value)

proc isSome*(self:Context, key:string):Future[bool] {.async.} =
  return await self.session.isSome(key)

proc get*(self:Context, key:string):Future[string] {.async.} =
  return await self.session.get(key)

proc delete*(self:Context, key:string) {.async.} =
  await self.session.delete(key)

proc destroy*(self:Context) {.async.} =
  await self.session.destroy()

proc setFlash*(self:Context, key, value:string) {.async.} =
  let key = "flash_" & key
  await self.session.set(key, value)

proc setFlash*(self:Context, key:string, value:JsonNode) {.async.} =
  let key = "flash_" & key
  await self.session.set(key, value)

proc hasFlash*(self:Context, key:string):Future[bool] {.async.} =
  if self.session.isSome:
    let rows = await self.session.get.db.getRows()
    for k, v in rows.pairs:
      if k.contains("flash_" & key):
        return true
  return false

proc getFlash*(self:Context):Future[JsonNode] {.async.} =
  result = newJObject()
  if self.session.isSome:
    let rows = await self.session.get.db.getRows()
    for key, val in rows.pairs:
      if key.contains("flash_"):
        var newKey = key[6..^1]
        result[newKey] = val
        await self.session.delete(key)

proc getErrors(self:Context):Future[JsonNode] {.async.} =
  result = newJObject()
  if self.session.isSome:
    let rows = self.session.get.db.getRows().await 
    for key, val in rows.pairs:
      if key == "flash_errors":
        self.session.delete(key).await
        return val

proc getParams(self:Context):Future[JsonNode] {.async.} =
  result = newJObject()
  if self.session.isSome:
    let rows = self.session.get.db.getRows().await
    for key, val in rows.pairs:
      if key == "flash_params":
        await self.session.delete(key)
        return val

proc getValidationResult*(self:Context):Future[tuple[params:JsonNode, errors:JsonNode]] {.async.} =
  return (self.getParams().await, self.getErrors().await)
