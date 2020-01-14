Middleware
===
[back](../README.md)

## Routing middleware
You can run middleware methods before calling controller.  
In following example, `hasLoginId(request)` and `hasLoginToken()` definded in `middleware/middlewares.nim` are called
```nim
import basolato/routing
import basolato/middleware

from middleware/middlewares import loginCheck, someMiddleware
import app/controllers/SomeController

router api:
  get "/api1":
    route(render("api1"))
  get "/api2":
    route(render("api2"))

routes:
  before re"/api.*":
    middleware([hasLoginId(request), hasLoginToken(request)])
  extend api, "/api"
```

middleware/middlewares.nim
```nim
import basolato/middleware

proc hasLoginId*(request: Request):Response =
  try:
    let loginId = request.headers["X-login-id"]
    echo "loginId ==========" & loginId
  except:
    raise newException(Error403, "Can't get login id")

proc hasLoginToken*(request: Request):Response =
  try:
    let loginToken = request.headers["X-login-token"]
    echo "loginToken =======" & loginToken
  except:
    raise newException(Error403, "Can't get login token")
```

If `X-login-id` or `X-login-token` are missing in request header, return 403 otherwise 200.