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
  params: Params
  session: Option[Session]

proc new*(_:type Context, request:Request, params:Params):Future[Context]{.async.} =
  return Context(
    request:request,
    params:params,
    session:none(Session)
  )


proc request*(self:Context):Request =
  return self.request


proc params*(self:Context):Params =
  return self.params


proc origin*(self:Context):string =
  return self.origin


proc setSession*(self:Context, session:Session) =
  self.session = session.some()


proc session*(self:Context):Option[Session] =
  return self.session


proc getToken*(self:Context):Future[string]{.async.} =
  return await self.session.getToken()


proc updateCsrfToken*(self:Context) {.async.} =
  await self.session.updateCsrfToken()


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
  ## ```
  ## params: {
  ##   "field1": "value1",
  ##   "field2": "value2"
  ## }
  ## errors: {
  ##   "field_name1": ["error message1", "error message2],
  ##   "field_name2": ["error message1", "error message2],
  ## }
  ## ```
  return (params: self.getParams().await, errors:self.getErrors().await)


proc getValidationErrors*(self:Context):Future[tuple[params:JsonNode, errors:seq[string]]] {.async.} =
  ## ```
  ## params: {
  ##   "field1": "value1",
  ##   "field2": "value2"
  ## }
  ## errors: [
  ##   "error message1",
  ##   "error message2",
  ## ]
  ## ```
  let sessionErrors = self.getErrors().await
  var errors:seq[string]
  for key, messages in sessionErrors.pairs:
    for message in messages:
      errors.add(message.getStr)
  return (params: self.getParams().await, errors:errors)


# ==================== Global Context ====================
var globalContext:Context

proc setContext*(c:Context) =
  globalContext = c

proc context*():Context =
  return globalContext
