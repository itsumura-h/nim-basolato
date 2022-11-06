import std/json
# framework
import basolato/controller
import ../views/pages/toppage_view


proc index*(context:Context, params:Params):Future[Response] {.async.} =
  if context.isLogin().await:
    return redirect("/home")
  return render(toppageView().await)

proc show*(context:Context, params:Params):Future[Response] {.async.} =
  let id = params.getInt("id")
  return render("show")

proc create*(context:Context, params:Params):Future[Response] {.async.} =
  return render("create")

proc store*(context:Context, params:Params):Future[Response] {.async.} =
  return render("store")

proc edit*(context:Context, params:Params):Future[Response] {.async.} =
  let id = params.getInt("id")
  return render("edit")

proc update*(context:Context, params:Params):Future[Response] {.async.} =
  let id = params.getInt("id")
  return render("update")

proc destroy*(context:Context, params:Params):Future[Response] {.async.} =
  let id = params.getInt("id")
  return render("destroy")
