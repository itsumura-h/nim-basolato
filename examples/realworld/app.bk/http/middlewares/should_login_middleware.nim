import std/asyncdispatch
import basolato/middleware


proc shouldLogin*(c:Context, p:Params):Future[Response] {.async.} =
  if not c.isLogin().await:
    return redirect("/sign-in")
  return next()


proc islandShouldLogin*(c:Context, p:Params):Future[Response] {.async.} =
  if not c.isLogin().await:
    let header = {
      "HX-Redirect": "/sign-in"
    }.newHttpHeaders()
    return render(Http303, "", header)
  return next()
