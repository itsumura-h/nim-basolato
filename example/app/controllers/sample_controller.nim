import json, strformat, strutils, times
import ../../../src/basolato/controller

import allographer/query_builder

# html
import ../../resources/sample/vue
import ../../resources/sample/react
import ../../../src/basolato/sample/resources/welcome
import ../../resources/sample/cookie

type SampleController = ref object of Controller

proc newSampleController*(request:Request): SampleController =
  return SampleController.newController(request)


proc index*(this:SampleController): Response =
  return render(html("sample/index.html"))


proc welcome*(this:SampleController): Response =
  let name = "Basolato " & basolatoVersion
  return render(welcomeHtml(name))


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
  return render(react_html($users))


proc vue*(this:SampleController): Response =
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
  return render(vue_html($header, $users))


proc customHeaders*(this:SampleController): Response =
  return render("with header")
          .header("Controller-Header-Key1", "Controller-Header-Val1")
          .header("Controller-Header-Key1", "Controller-Header-Val2")
          .header("Controller-Header-Key2", ["val1", "val2", "val3"])

proc indexCookie*(this:SampleController): Response =
  return render(cookieHtml(this.auth))

proc storeCookie*(this:SampleController): Response =
  let key = this.request.params["key"]
  let value = this.request.params["value"]
  let cookie = newCookie(key, value)
  return render(cookieHtml(this.auth)).setCookie(cookie)

<<<<<<< HEAD
proc destroyCookie*(this:SampleController): Response =
  let key = this.request.params["key"]
  return redirect("/sample/cookie")
          .deleteCookies(this.request, key)
=======
proc updateCookie*(this:SampleController): Response =
  let key = this.request.params["key"]
  let days = this.request.params["days"].parseInt
  return redirect("/sample/cookie")
          .updateCookieExpire(this.request, key, days)

proc destroyCookie*(this:SampleController): Response =
  let key = this.request.params["key"]
  return redirect("/sample/cookie")
          .deleteCookie(key)

proc destroyCookies*(this:SampleController): Response =
  # not work until https://github.com/dom96/jester/pull/237 is mearged and release
  return redirect("/sample/cookie")
          .deleteCookies(this.request)
>>>>>>> 0422fbd4fbb574598107f23aa87245f4397934bb
