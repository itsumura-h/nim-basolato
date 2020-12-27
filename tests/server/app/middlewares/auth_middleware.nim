import asyncdispatch
import ../../../../src/basolato/middleware

proc checkCsrfTokenMiddleware*(r:Request, p:Params) {.async.} =
  let resp = await checkCsrfToken(r, p)
  if resp.isError():
    raise newException(Error403, resp.message)

proc checkAuthTokenMiddleware*(r:Request, p:Params) {.async.} =
  let resp = await checkAuthToken(r)
  if resp.isError():
    raise newException(Error403, resp.message)
