import asyncdispatch
import ../../../../../src/basolato/middleware

proc setMiddleware1*(r:Request, p:Params):Future[Response] {.async.} =
  let headers = newHttpHeaders()
  headers.add("middleware1", "a")
  return next(headers=headers)
