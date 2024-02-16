import asyncdispatch
import ../../../../../src/basolato/middleware

proc checkCsrfToken*(c:Context, p:Params):Future[Response] {.async.} =
  let res = await middleware.checkCsrfToken(c.request, p)
  if res.hasError():
    echo res.message
    return render(Http403, res.message)
  return next()


proc checkCsrfToken*(c:Context, p:Params):Future[Response] {.async.} =
  let res = await middleware.checkCsrfToken(c.request, p)
  if res.hasError():
    echo res.message
    return render(Http403, res.message)
  return next()


proc checkSessionId*(c:Context, p:Params):Future[Response] {.async.} =
  let res = await middleware.checkSessionId(c.request)
  if res.hasError():
    return render(Http403, res.message)
  return next()
