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

<!-- Added by: root, at: Wed Jun 15 11:34:11 UTC 2022 -->

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
`newHttpHeaders()` generate `HttpHeaders` object from `openArray[tuple[key: string, val: string]]`.  
https://nim-lang.org/docs/httpcore.html#HttpHeaders

```nim
let headers = {
  "Strict-Transport-Security": "max-age=63072000, includeSubdomains",
  "X-Frame-Options": "SAMEORIGIN",
  "X-XSS-Protection": "1, mode=block",
  "X-Content-Type-Options": "nosniff",
  "Referrer-Policy": "no-referrer, strict-origin-when-cross-origin",
  "Cache-control": "no-cache, no-store, must-revalidate",
  "Pragma": "no-cache",
}.newHttpHeaders()
```

### Set headers in controller
Create header instance by `newHttpHeaders()` and add key and value. Finally, set header at the last arge of response.
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let headers = newHttpHeaders()
  headers.add("Controller-Header-Key1", ["Controller-Header-Val1", "Controller-Header-Val2"])
  headers.add("Controller-Header-Key2", ["val1", "val2", "val3"])
  return render("with header", headers)
```
