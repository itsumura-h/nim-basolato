import asyncdispatch
import ../../../../../src/basolato/middleware


proc checkCsrfToken*(c:Context, p:Params):Future[Response] {.async.} =
  let res = await checkCsrfToken(c.request, p)
  if res.hasError:
    return render(Http403, res.message)
  return next()

proc checkSessionId*(c:Context, p:Params):Future[Response] {.async.} =
  let res = await checkSessionId(c.request)
  if res.hasError:
    return errorRedirect("/signin")
  return next()
