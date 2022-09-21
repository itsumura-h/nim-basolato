import
  std/asyncdispatch,
  std/httpcore,
  std/net,
  ../../../src/basolato2/middleware


proc aMiddleware*(c:Context, params:Params):Future[Response] {.async.} =
  if not c.request.headers.hasKey("X-login-token"):
    raise newException(Error403, "リクエストヘッダーにX-login-tokenがありません")
  return next()

proc setCorsHeadersMiddleware*(c:Context, params:Params):Future[Response] {.async.} =
  const allowedMethods = [
    "OPTIONS",
    "GET",
    "POST",
    "PUT",
    "DELETE"
  ]

  const allowedHeaders = [
    "Access-Control-Allow-Origin",
    "Content-Type",
    "*",
  ]

  let headers = {
    "Origin": @[$true],
    "Cache-Control": @["no-cache"],
    "Access-Control-Allow-Credentials": @[$true],
    "Access-Control-Allow-Origin": @["http://localhost:3000"],
    "Access-Control-Allow-Methods": @allowedMethods,
    "Access-Control-Allow-Headers": @allowedHeaders,
    "Access-Control-Expose-Headers": @allowedHeaders,
  }.newHttpHeaders()
  if c.request.httpMethod == HttpOptions:
    return next(status=Http204, headers=headers)
  return next(headers=headers)


proc setSecureHeadersMiddlware*(c:Context, params:Params):Future[Response] {.async.} =
  let headers = {
    "Strict-Transport-Security": @["max-age=63072000", "includeSubdomains"],
    "X-Frame-Options": @["SAMEORIGIN"],
    "X-XSS-Protection": @["1", "mode=block"],
    "X-Content-Type-Options": @["nosniff"],
    "Referrer-Policy": @["no-referrer", "strict-origin-when-cross-origin"],
    "Cache-Control": @["no-cache", "no-store", "must-revalidate"],
    "Pragma": @["no-cache"],
  }.newHttpHeaders()
  if c.request.httpMethod == HttpOptions:
    return next(status=Http204, headers=headers)
  return next(headers=headers)
