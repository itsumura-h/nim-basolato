Headers
===
[back](../../README.md)

Table of Contents

<!--ts-->
   * [Headers](#headers)
      * [Request Header](#request-header)
      * [Response header](#response-header)
         * [Type of headers](#type-of-headers)
         * [Set headers in controller](#set-headers-in-controller)

<!-- Added by: root, at: Sun Dec 27 18:21:04 UTC 2020 -->

<!--te-->

## Request Header
To get request header, use `request.headers`

middleware/check_login.nim
```nim
import basolato/middleware

proc hasLoginId*(request:Request, params:Params):Future[Response] {.async.} =
  try:
    let loginId = request.headers["X-login-id"]
  except:
    raise newException(Error403, "Can't get login id")
```

app/controllers/sample_controller.nim
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let loginId = request.headers["X-login-id"]
```

## Response header
### Type of headers
`toHeaders()` generate `Header` object from `array`, `seq`, `table` and `JsonNode`.  
[sample code](../../tests/test_header.nim)


```nim
let headers = [
  ("Strict-Transport-Security", ["max-age=63072000", "includeSubdomains"].join(", ")),
  ("X-Frame-Options", "SAMEORIGIN"),
  ("X-XSS-Protection", ["1", "mode=block"].join(", ")),
  ("X-Content-Type-Options", "nosniff"),
  ("Referrer-Policy", ["no-referrer", "strict-origin-when-cross-origin"].join(", ")),
  ("Cache-control", ["no-cache", "no-store", "must-revalidate"].join(", ")),
  ("Pragma", "no-cache"),
].toHeaders()
```


### Set headers in controller
Create header instance by `newHeaders()` and add by `set()`. Finally, set header at the last arge of response.
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  var header = newHeaders()
  header.set("Controller-Header-Key1", "Controller-Header-Val1")
  header.set("Controller-Header-Key1", "Controller-Header-Val2")
  header.set("Controller-Header-Key2", ["val1", "val2", "val3"])
  return render("with header", header)
```
