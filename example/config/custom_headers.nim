from strutils import join

import ../../src/basolato/base


proc corsHeader*(): seq =
  var headers = @[
    ("Cache-Control", "no-cache"),
    ("Access-Control-Allow-Origin", "*")
  ]

  var allowedMethods = @[
    "OPTIONS",
    "GET",
    "POST",
    "PUT",
    "DELETE"
  ]
  if allowedMethods[0] != "":
    headers.add(("Access-Control-Allow-Methods", allowedMethods.join(", ")))

  var allowedHeaders = @[
    "X-login-id"
  ]
  if allowedHeaders[0] != "":
    headers.add(("Access-Control-Allow-Headers", allowedHeaders.join(", ")))

  return headers

proc middlewareHeader*():seq =
  return @[
    ("MiddlewareHeaderStatus", "ヘッダーあり"),
    ("key1", "val1")
  ]