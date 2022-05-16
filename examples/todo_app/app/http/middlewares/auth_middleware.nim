import asyncdispatch
import ../../../../../src/basolato/middleware

proc checkCsrfTokenMiddleware*(c:Context, p:Params):Future[Response] {.async.} =
  let res = checkCsrfToken(c.request, p).await
  if res.hasError:
    raise newException(Error403, res.message)
  return next()

proc checkSessionIdMiddleware*(c:Context, p:Params):Future[Response] {.async.} =
  let res = checkSessionId(c.request).await
  if res.hasError:
    raise newException(ErrorRedirect, "/signin")
  return next()

proc loginSkip*(c:Context, p:Params):Future[Response] {.async.} =
  if c.isLogin().await:
    raise newException(ErrorRedirect, "/todo")
  return next()

proc mustBeLoggedIn*(c:Context, p:Params):Future[Response] {.async.} =
  if not c.isLogin().await:
    raise newException(ErrorRedirect, "/signin")
  return next()
