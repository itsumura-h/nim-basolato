import json, strformat, strutils, times
import ../../../src/basolato/controller

import allographer/query_builder

# html
import ../../../src/basolato/welcome_page/resources/welcome
import ../../resources/sample/karax
import ../../resources/sample/react
import ../../resources/sample/material_ui
import ../../resources/sample/vuetify
import ../../resources/sample/cookie
import ../../resources/sample/login

type SampleController = ref object of Controller

proc newSampleController*(request:Request): SampleController =
  return SampleController.newController(request)


proc index*(this:SampleController): Response =
  return render(html("sample/index.html"))


proc welcome*(this:SampleController): Response =
  let name = "Basolato " & basolatoVersion
  return render(welcomeHtml(name))


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
  let header = newHeaders()
                .set("Controller-Header-Key1", "Controller-Header-Val1")
                .set("Controller-Header-Key1", "Controller-Header-Val2")
                .set("Controller-Header-Key2", ["val1", "val2", "val3"])
  return render("with header").setHeader(header)

# ========== Cookie ==================== 
proc indexCookie*(this:SampleController): Response =
  return render(cookieHtml(this.auth))

proc storeCookie*(this:SampleController): Response =
  let key = this.request.params["key"]
  let value = this.request.params["value"]
  let cookie = newCookie(this.request)
                .set(key, value)
  return render(cookieHtml(this.auth)).setCookie(cookie)

proc updateCookie*(this:SampleController): Response =
  let key = this.request.params["key"]
  let days = this.request.params["days"].parseInt
  let cookie = newCookie(this.request)
                .updateExpire(key, days, Days)
  return redirect("/sample/cookie").setCookie(cookie)

proc destroyCookie*(this:SampleController): Response =
  let key = this.request.params["key"]
  let cookie = newCookie(this.request)
                .delete(key)
  return redirect("/sample/cookie").setCookie(cookie)

proc destroyCookies*(this:SampleController): Response =
  # TODO: not work until https://github.com/dom96/jester/pull/237 is mearged and release
  let cookie = newCookie(this.request)
                .destroy()
  return redirect("/sample/cookie").setCookie(cookie)

# ========== Login ====================
proc indexLogin*(this:SampleController): Response =
  return render(loginHtml(this.auth))

proc storeLogin*(this:SampleController): Response =
  let name = this.request.params["name"]
  let password = this.request.params["password"]
  echo name, password
  # auth
  let auth = newAuth().set("name", name)
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
  # dd(
  #   $a,
  #   "abc",
  #   # this.request.repr,
  # )
  echo "a"
  echo "b"
  # dd("abc")
  return render("dd")