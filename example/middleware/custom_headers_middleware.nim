from strutils import join


proc customHeader*():seq =
  return @[
    ("Middleware-Header-Key1", "Middleware-Header-Val1"),
    ("Middleware-Header-Key2", ["val1", "val2", "val3"].join(", "))
  ]


proc corsHeader*(): seq =
  var allowedMethods = @[
    "OPTIONS",
    "GET",
    "POST",
    "PUT",
    "DELETE"
  ]

  var allowedHeaders = @[
    "X-login-id",
    "X-login-token"
  ]

  return @[
    ("Cache-Control", "no-cache"),
    ("Access-Control-Allow-Origin", "*"),
    ("Access-Control-Allow-Methods", allowedMethods.join(", ")),
    ("Access-Control-Allow-Headers", allowedHeaders.join(", "))
  ]


proc secureHeader*(): seq =
  return @[
    ("Strict-Transport-Security", ["max-age=63072000", "includeSubdomains"].join(", ")),
    ("X-Frame-Options", "SAMEORIGIN"),
    ("X-XSS-Protection", ["1", "mode=block"].join(", ")),
    ("X-Content-Type-Options", "nosniff"),
    ("Referrer-Policy", ["no-referrer", "strict-origin-when-cross-origin"].join(", ")),
    ("Cache-control", ["no-cache", "no-store", "must-revalidate"].join(", ")),
    ("Pragma", "no-cache"),
  ]
