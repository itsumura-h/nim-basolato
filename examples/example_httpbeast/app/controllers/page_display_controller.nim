import json, times, strformat
# framework
import ../../../../src/basolato_httpbeast/controller
import allographer/query_builder
# view
import ../../resources/pages/welcome_view
import ../../resources/pages/sample/react
import ../../resources/pages/sample/material_ui
import ../../resources/pages/sample/vuetify


let indexHtml = html("pages/sample/index.html")

proc index*(request:Request, params:Params):Future[Response] {.async.} =
  return render(indexHtml)

proc welcome*(request:Request, params:Params):Future[Response] {.async.} =
  let name = "Basolato " & basolatoVersion
  return render(welcomeView(name))

proc fib_logic(n: int): int =
  if n < 2:
    return n
  return fib_logic(n - 2) + fib_logic(n - 1)

proc fib*(request:Request, params:Params):Future[Response] {.async.} =
  let num = params.urlParams["num"].getInt
  var results: seq[int]
  let start_time = getTime()
  for i in 0..<num:
    results.add(fib_logic(i))
  let end_time = getTime() - start_time # Duration type
  var data = %*{
    "version": "Nim " & NimVersion,
    "time": &"{end_time.inSeconds}.{end_time.inMicroseconds}",
    "fib": results
  }
  return render(data)


proc react*(request:Request, params:Params):Future[Response] {.async.} =
  let users = %*RDB().table("users")
              .select("users.id", "users.name", "users.email", "auth.auth")
              .join("auth", "auth.id", "=", "users.auth_id")
              .get()
  return render(reactHtml($users))

proc materialUi*(request:Request, params:Params):Future[Response] {.async.} =
  let users = %*RDB().table("users")
              .select("users.id", "users.name", "users.email", "auth.auth")
              .join("auth", "auth.id", "=", "users.auth_id")
              .get()
  return render(materialUiHtml($users))


proc vuetify*(request:Request, params:Params):Future[Response] {.async.} =
  let users = %*RDB().table("users")
              .select("users.id", "users.name", "users.email", "auth.auth")
              .join("auth", "auth.id", "=", "users.auth_id")
              .get()
  let header = %*[
    {"text": "id", "value": "id"},
    {"text": "name", "value": "name"},
    {"text": "email", "value": "email"},
    {"text": "auth", "value": "auth"},
    {"text": "created_at", "value": "created_at"},
    {"text": "updated_at", "value": "updated_at"}
  ]
  return render(vuetifyHtml($header, $users))


proc customHeaders*(request:Request, params:Params):Future[Response] {.async.} =
  var header = newHeaders()
  header.set("Controller-Header-Key1", "Controller-Header-Val1")
  header.set("Controller-Header-Key1", "Controller-Header-Val2")
  header.set("Controller-Header-Key2", ["val1", "val2", "val3"])
  header.set("setHeaderTest", "aaaa")
  return render("with header", header)

proc presentDd*(request:Request, params:Params):Future[Response] {.async.} =
  var a = %*{
    "key1": "value1",
    "key2": "value2",
    "key3": "value3",
    "key4": "value4",
  }
  dd(
    $a,
    "abc",
    # request.repr,
  )
  return render("dd")

proc errorPage*(request:Request, params:Params):Future[Response] {.async.} =
  let id = params.urlParams["id"].getInt
  if id mod 2 == 1:
    raise newException(Error400, "")
  return render($id)

proc errorRedirect*(request:Request, params:Params):Future[Response] {.async.} =
  let id = params.urlParams["id"].getInt
  if id mod 2 == 1:
    raise newException(ErrorRedirect, "/sample/login")
  return render($id)