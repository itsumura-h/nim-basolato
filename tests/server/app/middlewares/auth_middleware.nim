import asyncdispatch
import ../../../../src/basolato/middleware

proc checkCsrfTokenMiddleware*(r:Request, p:Params):Future[Response] {.async.} =
  let resp = await checkCsrfToken(r, p)
  if resp.isError():
    raise newException(Error403, resp.message)
  return next()

proc checkAuthTokenMiddleware*(r:Request, p:Params):Future[Response] {.async.} =
  let resp = await checkAuthToken(r)
  if resp.isError():
    raise newException(Error403, resp.message)
  return next()
