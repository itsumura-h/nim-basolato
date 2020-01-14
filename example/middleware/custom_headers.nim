from strutils import join


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
    "X-login-id",
    "X-login-token"
  ]
  if allowedHeaders[0] != "":
    headers.add(("Access-Control-Allow-Headers", allowedHeaders.join(", ")))

  return headers


proc middlewareHeader*():seq =
  return @[
    ("Middleware-Header-Key1", "Middleware-Header-Val1"),
    ("Middleware-Header-Key2", ["val1", "val2", "val3"].join(", "))
  ]