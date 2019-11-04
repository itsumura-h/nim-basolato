import ../../src/shihotsuchi


proc corsHeader*(request: Request): seq =
  var headers = @[
    ("Cache-Control", "no-cache"),
    ("Access-Control-Allow-Origin", "*")
  ]

  var allowedMethods = [
    "OPTIONS",
    "GET",
    "POST",
    "PUT",
    "DELETE"
  ]
  if allowedMethods[0] != "":
    headers.add(("Access-Control-Allow-Methods", allowedMethods.join(", ")))

  var allowedHeaders = [
    "X-login-id"
  ]
  if allowedHeaders[0] != "":
    headers.add(("Access-Control-Allow-Headers", allowedHeaders.join(", ")))

  return headers
