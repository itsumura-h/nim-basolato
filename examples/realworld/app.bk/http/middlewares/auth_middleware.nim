import std/asyncdispatch
import std/json
import basolato/middleware


proc checkSessionId*(c:Context, p:Params):Future[Response] {.async.} =
  let res = await checkSessionId(c.request)
  if res.hasError:
    return errorRedirect("/sign-in")
  return next()


proc loginSkip*(c:Context, p:Params):Future[Response] {.async.} =
  if c.isLogin().await:
    return redirect("/")
  return next()
