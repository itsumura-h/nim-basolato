from strutils import join
import asyncdispatch
import ../../../../../../src/basolato/middleware


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
    "Cache-Control": "no-cache",
    "Access-Control-Allow-Credentials": $true,
    "Access-Control-Allow-Origin": "http://localhost:3000",
    "Access-Control-Allow-Methods": allowedMethods.join(", "),
    "Access-Control-Allow-Headers": allowedHeaders.join(", "),
    "Access-Control-Expose-Headers": allowedHeaders.join(", "),
  }.newHttpHeaders()


proc secureHeader(): HttpHeaders =
  return {
    "Strict-Transport-Security": ["max-age=63072000", "includeSubdomains"].join(", "),
    "X-Frame-Options": "SAMEORIGIN",
    "X-XSS-Protection": ["1", "mode=block"].join(", "),
    "X-Content-Type-Options": "nosniff",
    "Referrer-Policy": ["no-referrer", "strict-origin-when-cross-origin"].join(", "),
    "Cache-Control": ["no-cache", "no-store", "must-revalidate"].join(", "),
    "Pragma": "no-cache",
  }.newHttpHeaders()

proc setCorsHeadersMiddleware*(r:Request, p:Params):Future[Response] {.async.} =
  let headers = corsHeader() & secureHeader()
  return next(status=Http204, headers=headers)