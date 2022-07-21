import asyncdispatch
import ../../../../../src/basolato2/middleware

proc setMiddleware1*(c:Context, p:Params):Future[Response] {.async.} =
  let headers = newHttpHeaders()
  headers.add("middleware1", "a")
  return next(headers=headers)

proc setMiddleware2*(c:Context, p:Params):Future[Response] {.async.} =
  let headers = newHttpHeaders()
  headers.add("middleware2", "b")
  return next(headers=headers)

proc setMiddleware3*(c:Context, p:Params):Future[Response] {.async.} =
  let headers = newHttpHeaders()
  headers.add("middleware3", "c")
  return next(headers=headers)
