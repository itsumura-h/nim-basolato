Headers
===
[back](../README.md)

## Request Header
To get request header, use `request.headers`

middleware/check_login.nim
```nim
import basolato/middleware

proc hasLoginId*(request: Request):Response =
  try:
    let loginId = request.headers["X-login-id"]
  except:
    raise newException(Error403, "Can't get login id")
```

app/controllers/sample_controller.nim
```nim
proc index*(this:SampleController): Response =
  let loginId = this.request.headers["X-login-id"]
```

## Response header
### Type of headers
`toHeaders()` generate `Header` object from `array`, `seq`, `table` and `JsonNode`.

```nim
import ../../src/basolato/middleware

proc secureHeader*(): Headers =
  return [
    ("Strict-Transport-Security", ["max-age=63072000", "includeSubdomains"].join(", ")),
    ("X-Frame-Options", "SAMEORIGIN"),
    ("X-XSS-Protection", ["1", "mode=block"].join(", ")),
    ("X-Content-Type-Options", "nosniff"),
    ("Referrer-Policy", ["no-referrer", "strict-origin-when-cross-origin"].join(", ")),
    ("Cache-control", ["no-cache", "no-store", "must-revalidate"].join(", ")),
    ("Pragma", "no-cache"),
  ].toHeaders()
```


### Set headers in routing
You can set custom headers by setting 2nd arg or `route()`  
Procs which return custom headers have to return seq `@[(key, val: string)]`

```nim
import basolato/routing

from config/custom_headers import corsHeader
import app/controllers/SomeController

routes:
  get "/":
    route(SomeController.index(), [corsHeader(request), secureHeader()])
```

To set custom headers for specific URL group, use `after` verb
```nim
after re"/api.*":
  route(response(result), [corsHeader(request), secureHeader()])
extend api, "/api"
```

### Set headers in controller
Create header instance by `newHeaders()` and add by `set()`. Finally, set header to response with `setHeader()`
```nim
proc index*(this:SampleController): Response =
  let header = newHeaders()
                .set("Controller-Header-Key1", "Controller-Header-Val1")
                .set("Controller-Header-Key1", "Controller-Header-Val2")
                .set("Controller-Header-Key2", ["val1", "val2", "val3"])
  return render("with header").setHeader(header)
```
