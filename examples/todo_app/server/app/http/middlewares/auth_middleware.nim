import asyncdispatch
import ../../../../../../src/basolato/middleware

proc checkCsrfTokenMiddleware*(r:Request, p:Params):Future[Response] {.async.} =
  let res = await checkCsrfToken(r, p)
  if res.hasError:
    raise newException(Error403, res.message)
  return next()

proc checkSessionIdMiddleware*(r:Request, p:Params):Future[Response] {.async.} =
  let res = await checkSessionId(r)
  if res.hasError:
    raise newException(ErrorRedirect, "/signin")
  return next()

proc checkLoginMiddleware*(r:Request, p:Params):Future[Response] {.async.} =
  let client = await newClient(r)
  if not await client.isLogin():
    raise newException(ErrorAuthRedirect, "/signin")
  return next()
