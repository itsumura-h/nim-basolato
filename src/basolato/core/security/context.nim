import std/asyncdispatch 
import std/httpcore
import std/options
import std/strutils
import std/json
import ../params
import ./session
import ./csrf_token
import ./session_db

when defined(httpbeast) or defined(httpx):
  from ../libservers/nostd/request import Request, headers
else:
  from ../libservers/std/request import Request


type Context* = ref object
  request: Request
  params: Params
  sessionOpt: Option[Session]
  csrfToken: CsrfToken
  ## flash に保存された入力・エラーの読み出し結果をキャッシュする
  flashParamsCache: Option[Params]
  flashErrorsCache: Option[JsonNode]

## セッション値ストアへの低レベル操作を提供するアクセサ。
## 利用者は `Option[Session]` を意識せず `context.session.get(...)` 等を扱える。
type ContextSession* = object
  sessionOpt: Option[Session]

proc new*(_:type Context, request:Request, params:Params):Future[Context]{.async.} =
  return Context(
    request:request,
    params:params,
    sessionOpt:none(Session),
    csrfToken: CsrfToken.new(),
    flashParamsCache: none(Params),
    flashErrorsCache: none(JsonNode)
  )


proc request*(self:Context):Request =
  return self.request


proc params*(self:Context):Params =
  return self.params


proc origin*(self:Context):string =
  if self.request.headers.hasKey("Origin"):
    return self.request.headers["Origin"]
  return ""


proc setCsrfToken*(self:Context, token:string) =
  self.csrfToken = CsrfToken.new(token)


proc getCsrfToken*(self:Context):string =
  return self.csrfToken.getToken()


proc csrfToken*(self: Context): CsrfToken =
  return self.csrfToken


proc setSession*(self:Context, session:Session) {.async.} =
  self.sessionOpt = session.some()
  ## セッションに保存されている CSRF トークンを Context に取り込む
  if await self.sessionOpt.isSome("csrf_token"):
    let token = await self.sessionOpt.get("csrf_token")
    self.csrfToken = CsrfToken.new(token)
  else:
    self.csrfToken = CsrfToken.new()


proc session*(self:Context):ContextSession =
  return ContextSession(sessionOpt: self.sessionOpt)


proc get*(self:ContextSession, key:string):Future[string] {.async.} =
  return await self.sessionOpt.get(key)


proc set*(self:ContextSession, key, value:string) {.async.} =
  await self.sessionOpt.set(key, value)


proc set*(self:ContextSession, key:string, value:JsonNode) {.async.} =
  await self.sessionOpt.set(key, value)


proc isSome*(self:ContextSession, key:string):Future[bool] {.async.} =
  return await self.sessionOpt.isSome(key)


proc delete*(self:ContextSession, key:string) {.async.} =
  await self.sessionOpt.delete(key)


proc getToken*(self:ContextSession):Future[string] {.async.} =
  return await self.sessionOpt.getToken()


proc updateCsrfToken*(self:ContextSession):Future[string] {.async.} =
  return await self.sessionOpt.updateCsrfToken()


proc destroy*(self:ContextSession) {.async.} =
  await self.sessionOpt.destroy()


proc getToken*(self:Context):Future[string]{.async.} =
  return await self.session.getToken()


proc updateCsrfToken*(self:Context):Future[string] {.async.} =
  let csrfToken = await self.session.updateCsrfToken()
  self.csrfToken = CsrfToken.new(csrfToken)
  return csrfToken


proc login*(self:Context){.async.} =
  await self.sessionOpt.set("is_login", $true)


proc logout*(self:Context){.async.} =
  await self.sessionOpt.delete("is_login")


proc isLogin*(self:Context):Future[bool]{.async.} =
  if await self.sessionOpt.isSome("is_login"):
    return parseBool(await self.sessionOpt.get("is_login"))
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
  await self.sessionOpt.set(key, value)


proc setFlash*(self:Context, key:string, value:JsonNode) {.async.} =
  let key = "flash_" & key
  await self.sessionOpt.set(key, value)


proc hasFlash*(self:Context, key:string):Future[bool] {.async.} =
  if self.sessionOpt.isSome:
    let rows = await self.sessionOpt.get.db.getRows()
    let flashKey = "flash_" & key
    for k, v in rows.pairs:
      if k == flashKey:
        return true
  return false


proc getFlash*(self:Context):Future[JsonNode] {.async.} =
  result = newJObject()
  if self.sessionOpt.isSome:
    let rows = await self.sessionOpt.get.db.getRows()
    for key, val in rows.pairs:
      if key.len >= 6 and key[0..5] == "flash_":
        var newKey = key[6..^1]
        result[newKey] = val
        await self.sessionOpt.delete(key)


proc getErrorsObject*(self:Context):Future[JsonNode] {.async.} =
  if self.flashErrorsCache.isSome:
    return self.flashErrorsCache.get()

  result = newJObject()
  if self.sessionOpt.isSome:
    let rows = self.sessionOpt.get.db.getRows().await
    for key, val in rows.pairs:
      if key == "flash_errors":
        self.sessionOpt.delete(key).await
        self.flashErrorsCache = some(val)
        return val

  self.flashErrorsCache = some(result)


proc getErrors*(self:Context):Future[seq[string]] {.async.} =
  var flatErrors: seq[string]
  let sessionErrors = await self.getErrorsObject()
  for _, messages in sessionErrors.pairs:
    for message in messages:
      flatErrors.add(message.getStr)
  return flatErrors


proc getParams*(self:Context):Future[Params] {.async.} =
  if self.flashParamsCache.isSome:
    return self.flashParamsCache.get()

  result = Params.new()
  if self.sessionOpt.isSome:
    let rows = self.sessionOpt.get.db.getRows().await
    for key, sessionParams in rows.pairs:
      if key == "flash_params":
        await self.sessionOpt.delete(key)
        let params = Params.new()
        for key, jsonParam in sessionParams.pairs:
          params[key] = jsonParam.to(Param)
        self.flashParamsCache = some(params)
        return params

  self.flashParamsCache = some(result)


proc getParamsWithErrorsObject*(self:Context):Future[tuple[params:Params, errors:JsonNode]] {.async.} =
  ## ```
  ## params: {
  ##   "field1": {"value": "value1", fileName:"", ext:""},
  ##   "field2": {"value": "value2", fileName:"", ext:""}
  ## }
  ## errors: {
  ##   "field_name1": ["error message1", "error message2],
  ##   "field_name2": ["error message1", "error message2],
  ## }
  ## ```
  let params = await self.getParams()
  let errors = await self.getErrorsObject()
  return (params: params, errors:errors)


proc getParamsWithErrorsList*(self:Context):Future[tuple[params:Params, errors:seq[string]]] {.async.} =
  ## ```
  ## params: {
  ##   "field1": {"value": "value1", fileName:"", ext:""},
  ##   "field2": {"value": "value2", fileName:"", ext:""}
  ## }
  ## errors: [
  ##   "error message1",
  ##   "error message2",
  ## ]
  ## ```
  let params = await self.getParams()
  let errors = await self.getErrors()
  return (params: params, errors:errors)


# ==================== Global Context ====================
var globalContext:Context

proc setContext*(c:Context) =
  globalContext = c

proc context*():Context =
  return globalContext
