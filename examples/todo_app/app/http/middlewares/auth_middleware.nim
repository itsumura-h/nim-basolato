import asyncdispatch
import ../../../../../src/basolato/middleware

proc checkCsrfTokenMiddleware*(c:Context, p:Params):Future[Response] {.async.} =
  if c.request.httpMethod == HttpPost:
    let res = checkCsrfToken(c.request, p).await
    if res.hasError:
      return render(Http403, res.message)
  return next()

proc checkSessionIdMiddleware*(c:Context, p:Params):Future[Response] {.async.} =
  let res = checkSessionId(c.request).await
  if res.hasError:
    return errorRedirect("/signin")
  return next()

proc loginSkip*(c:Context, p:Params):Future[Response] {.async.} =
  if c.isLogin().await:
    return errorRedirect("/todo")
  return next()

proc mustBeLoggedIn*(c:Context, p:Params):Future[Response] {.async.} =
  echo "=== mustBeLoggedIn"
  echo "c.isLogin().await ",c.isLogin().await
  if not c.isLogin().await:
    return errorRedirect("/signin")
  return next()
