import asyncdispatch
import ../../../../../src/basolato/middleware

proc setMiddleware2*(r:Request, p:Params):Future[Response] {.async.} =
  let headers = newHttpHeaders()
  headers.add("middleware2", "b")
  return next(headers=headers)
