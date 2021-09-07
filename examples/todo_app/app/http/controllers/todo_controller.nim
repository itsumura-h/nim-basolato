import json
# framework
import ../../../../../src/basolato/controller
# view
import ../views/pages/todo/index_view

proc toppage*(context:Context, params:Params):Future[Response] {.async.} =
  return redirect("/todo")

proc index*(context:Context, params:Params):Future[Response] {.async.} =
  let id = await context.get("id")
  let name = await context.get("name")
  return render(indexView(id, name))

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
