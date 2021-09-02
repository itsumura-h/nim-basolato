from strutils import join
import asyncdispatch
import ../../../../../src/basolato/middleware


proc corsHeader(): HttpHeaders =
  let allowedMethods = [
    "OPTIONS",
    "GET",
    "POST",
    "PUT",
    "DELETE"
  ]

  let allowedHeaders = [
    "content-type",
  ]

  return {
    "Cache-Control": @["no-cache"],
    "Access-Control-Allow-Credentials": @[$true],
    "Access-Control-Allow-Origin": @["http://localhost:3000"],
    "Access-Control-Allow-Methods": @allowedMethods,
    "Access-Control-Allow-Headers": @allowedHeaders,
    "Access-Control-Expose-Headers": @allowedHeaders,
  }.newHttpHeaders()


proc secureHeader(): HttpHeaders =
  return {
    "Strict-Transport-Security": @["max-age=63072000", "includeSubdomains"].join(", "),
    "X-Frame-Options": @["SAMEORIGIN"].join(", "),
    "X-XSS-Protection": @["1", "mode=block"].join(", "),
    "X-Content-Type-Options": @["nosniff"].join(", "),
    "Referrer-Policy": @["no-referrer", "strict-origin-when-cross-origin"].join(", "),
    "Cache-Control": @["no-cache", "no-store", "must-revalidate"].join(", "),
    "Pragma": @["no-cache"].join(", "),
  }.newHttpHeaders()

proc setCorsMiddleware*(r:Request, p:Params):Future[Response] {.async.} =
  let headers = corsHeader() & secureHeader()
  return next(status=Http204, headers=headers)
