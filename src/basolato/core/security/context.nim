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
  pathParams: Params
  cachedParams: Option[Params]
  sessionOpt: Option[Session]
  csrfToken: CsrfToken
  ## flash に保存された入力・エラーの読み出し結果をキャッシュする
  flashParamsCache: Option[Params]
  flashErrorsCache: Option[JsonNode]
  ## `getFlash` 用: 同一リクエスト内の `getRows` 結果（書き込み時は無効化）
  sessionRowsCache: Option[JsonNode]
  ## `sessionFromCookieHelper` でデコード済みの JWT ペイロード（CSRF ミドルウェアで再利用）
  sessionJwtPayload: Option[JsonNode]

## セッション値ストアへの低レベル操作を提供するアクセサ。
## 利用者は `Option[Session]` を意識せず `context.session.get(...)` 等を扱える。
type ContextSession* = object
  sessionOpt: Option[Session]

proc invalidateSessionRowsCache(self: Context) =
  self.sessionRowsCache = none(JsonNode)

proc new*(_:type Context, request:Request, pathParams:Params=nil):Future[Context]{.async.} =
  let pp = if pathParams.isNil: Params.new() else: pathParams
  return Context(
    request:request,
    pathParams: pp,
    cachedParams: none(Params),
    sessionOpt:none(Session),
    csrfToken: CsrfToken.new(),
    flashParamsCache: none(Params),
    flashErrorsCache: none(JsonNode),
    sessionRowsCache: none(JsonNode),
    sessionJwtPayload: none(JsonNode)
  )


proc request*(self:Context):Request =
  return self.request


proc params*(self:Context): Params =
  if self.cachedParams.isNone:
    self.cachedParams = some(buildRequestParams(self.request, self.pathParams))
  return self.cachedParams.get()


proc setDecodedSessionJwt*(self: Context, payload: JsonNode) =
  self.sessionJwtPayload = some(payload)


proc decodedSessionJwt*(self: Context): Option[JsonNode] =
  return self.sessionJwtPayload


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
  self.invalidateSessionRowsCache()
  self.sessionJwtPayload = none(JsonNode)
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
  if key == "flash_params" or key == "flash_errors" or key.startsWith("flash_"):
    self.invalidateSessionRowsCache()
  await self.session.delete(key)


proc destroy*(self:Context) {.async.} =
  await self.session.destroy()


proc setFlash*(self:Context, key, value:string) {.async.} =
  self.invalidateSessionRowsCache()
  let key = "flash_" & key
  await self.sessionOpt.set(key, value)


proc setFlash*(self:Context, key:string, value:JsonNode) {.async.} =
  self.invalidateSessionRowsCache()
  let key = "flash_" & key
  await self.sessionOpt.set(key, value)


proc hasFlash*(self:Context, key:string):Future[bool] {.async.} =
  if self.sessionOpt.isSome:
    return await self.sessionOpt.isSome("flash_" & key)
  return false


proc getFlash*(self:Context):Future[JsonNode] {.async.} =
  result = newJObject()
  if not self.sessionOpt.isSome:
    return
  var rows: JsonNode
  if self.sessionRowsCache.isSome:
    rows = self.sessionRowsCache.get()
  else:
    rows = await self.sessionOpt.get.db.getRows()
    self.sessionRowsCache = some(rows)
  var keysToDelete: seq[string] = @[]
  for key, val in rows.pairs:
    if key.len >= 6 and key[0..5] == "flash_":
      let newKey = key[6..^1]
      result[newKey] = val
      keysToDelete.add(key)
  for key in keysToDelete:
    await self.sessionOpt.delete(key)
  self.invalidateSessionRowsCache()


proc getErrorsObject*(self:Context):Future[JsonNode] {.async.} =
  if self.flashErrorsCache.isSome:
    return self.flashErrorsCache.get()

  result = newJObject()
  if self.sessionOpt.isSome:
    if await self.sessionOpt.isSome("flash_errors"):
      let val = await self.sessionOpt.get.db.getJson("flash_errors")
      await self.sessionOpt.delete("flash_errors")
      self.invalidateSessionRowsCache()
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
    if await self.sessionOpt.isSome("flash_params"):
      let sessionParams = await self.sessionOpt.get.db.getJson("flash_params")
      await self.sessionOpt.delete("flash_params")
      self.invalidateSessionRowsCache()
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
