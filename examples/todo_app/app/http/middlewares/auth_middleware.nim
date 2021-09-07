import asyncdispatch
import ../../../../../src/basolato/middleware

proc checkCsrfTokenMiddleware*(c:Context, p:Params):Future[Response] {.async.} =
  let res = await checkCsrfToken(c.request, p)
  if res.hasError:
    raise newException(Error403, res.message)
  return next()

proc checkSessionIdMiddleware*(c:Context, p:Params):Future[Response] {.async.} =
  let res = await checkSessionId(c.request)
  if res.hasError:
    raise newException(ErrorRedirect, "/signin")
  return next()

proc redirectTodo*(c:Context, p:Params):Future[Response] {.async.} =
  echo c.request.path
  raise newException(ErrorRedirect, "/todo")
  return next()

proc loginSkip*(c:Context, p:Params):Future[Response] {.async.} =
  if await c.isLogin():
    raise newException(ErrorRedirect, "/todo")
  return next()

proc mustBeLoggedIn*(c:Context, p:Params):Future[Response] {.async.} =
  if not await c.isLogin():
    raise newException(ErrorRedirect, "/signin")
  return next()
