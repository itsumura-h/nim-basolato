import json, strformat, strutils, times
import ../../../src/basolato/controller

import allographer/query_builder

# html
import ../../resources/sample/vue
import ../../resources/sample/react


proc index*(): Response =
  return render(html("sample/index.html"))


proc fib_logic(n: int): int =
    if n < 2:
      return n
    return fib_logic(n - 2) + fib_logic(n - 1)


proc fib*(numArg: string): Response =
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


proc react*(): Response =
  let users = %*RDB().table("users")
              .select("users.id", "users.name", "users.email", "auth.auth")
              .join("auth", "auth.id", "=", "users.auth_id")
              .get()
  return render(react_html($users))


proc vue*(): Response =
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


proc customHeaders*(): Response =
  return render("with header")
          .header("Controller-Header-Key1", "Controller-Header-Val1")
          .header("Controller-Header-Key2", ["val1", "val2", "val3"])
