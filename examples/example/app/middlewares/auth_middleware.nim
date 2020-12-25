import asyncdispatch
import ../../../../src/basolato/middleware

proc checkCsrfTokenMiddleware*(r:Request, p:Params) {.async.} =
  let res = await checkCsrfToken(r, p)
  if res.isError:
    raise newException(Error403, res.message)

proc checkAuthTokenMiddleware*(r:Request, p:Params) {.async.} =
  let res = await checkAuthToken(r)
  if isError(res):
    raise newException(ErrorRedirect, "/signin")
