import std/asyncdispatch
import basolato/middleware


proc loginSkip*(c:Context):Future[Response] {.async.} =
  if c.isLogin().await:
    return redirect("/")
  return next()


proc loginRequired*(c:Context):Future[Response] {.async.} =
  if not c.isLogin().await:
    return redirect("/login")
  return next()
