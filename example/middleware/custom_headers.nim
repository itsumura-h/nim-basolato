import strutils

proc customHeader*():seq =
  return @[
    ("Middleware-Header-Key1", "Middleware-Header-Val1"),
    ("Middleware-Header-Key2", ["val1", "val2", "val3"].join(", "))
  ]
