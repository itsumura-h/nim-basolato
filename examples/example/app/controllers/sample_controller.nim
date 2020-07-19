import json, strformat, strutils, times
import basolato/controller

import allographer/query_builder

# html
import ../../resources/pages/welcome_view
import ../../resources/pages/sample/karax
import ../../resources/pages/sample/react
import ../../resources/pages/sample/material_ui
import ../../resources/pages/sample/vuetify
import ../../resources/pages/sample/cookie
import ../../resources/pages/sample/login

type SampleController = ref object of Controller

proc newSampleController*(request:Request): SampleController =
  return SampleController.newController(request)


proc index*(this:SampleController): Response =
  return render(html("pages/sample/index.html"))


proc welcome*(this:SampleController): Response =
  let name = "Basolato " & basolatoVersion
  return render(this.view.welcomeView(name))


proc karaxIndex*(this:SampleController): Response =
  return render(karaxHtml())


proc fib_logic(n: int): int =
  if n < 2:
    return n
  return fib_logic(n - 2) + fib_logic(n - 1)

proc fib*(this:SampleController, numArg: string): Response =
  let num = numArg.parseInt
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


proc react*(this:SampleController): Response =
  let users = %*RDB().table("users")
              .select("users.id", "users.name", "users.email", "auth.auth")
              .join("auth", "auth.id", "=", "users.auth_id")
              .get()
  # dd($users)
  return render(reactHtml($users))

proc materialUi*(this:SampleController): Response =
  let users = %*RDB().table("users")
              .select("users.id", "users.name", "users.email", "auth.auth")
              .join("auth", "auth.id", "=", "users.auth_id")
              .get()
  return render(materialUiHtml($users))


proc vuetify*(this:SampleController): Response =
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


proc customHeaders*(this:SampleController): Response =
  var header = newHeaders()
  header.set("Controller-Header-Key1", "Controller-Header-Val1")
  header.set("Controller-Header-Key1", "Controller-Header-Val2")
  header.set("Controller-Header-Key2", ["val1", "val2", "val3"])
  header.set("setHeaderTest", "aaaa")
  return render("with header").setHeader(header)

# ========== Cookie ==================== 
proc indexCookie*(this:SampleController): Response =
  return render(cookieHtml(this.auth))

proc storeCookie*(this:SampleController): Response =
  let key = this.request.params["key"]
  let value = this.request.params["value"]
  var cookie = newCookie(this.request)
  cookie.set(key, value)
  return render(cookieHtml(this.auth)).setCookie(cookie)

proc updateCookie*(this:SampleController): Response =
  let key = this.request.params["key"]
  let days = this.request.params["days"].parseInt
  var cookie = newCookie(this.request)
  cookie.updateExpire(key, days, Days)
  return redirect("/sample/cookie").setCookie(cookie)

proc destroyCookie*(this:SampleController): Response =
  let key = this.request.params["key"]
  var cookie = newCookie(this.request)
  cookie.delete(key)
  return redirect("/sample/cookie").setCookie(cookie)

proc destroyCookies*(this:SampleController): Response =
  # TODO: not work until https://github.com/dom96/jester/pull/237 is mearged and release
  var cookie = newCookie(this.request)
  cookie.destroy()
  return redirect("/sample/cookie").setCookie(cookie)

# ========== Login ====================
proc indexLogin*(this:SampleController): Response =
  let auth = newAuth(this.request)
  return render(loginHtml(auth))

proc storeLogin*(this:SampleController): Response =
  let name = this.request.params["name"]
  let password = this.request.params["password"]
  # auth
  let auth = newAuth()
  auth.login()
  auth.set("name", name)
  return redirect("/sample/login").setAuth(auth)

proc destroyLogin*(this:SampleController): Response =
  return redirect("/sample/login").destroyAuth(this.auth)

proc presentDd*(this:SampleController): Response =
  var a = %*{
    "key1": "value1",
    "key2": "value2",
    "key3": "value3",
    "key4": "value4",
  }
  dd(
    $a,
    "abc",
    # this.request.repr,
  )
  return render("dd")
