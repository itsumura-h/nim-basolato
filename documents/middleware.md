Middleware
===
[back](../README.md)

## Routing middleware
You can run middleware methods before calling controller.  
In following example, `hasLoginId(request)` and `hasLoginToken()` definded in `middleware/check_login_middleware.nim` are called

middleware/check_login_middleware.nim
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

main.nim
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

If `X-login-id` or `X-login-token` are missing in request header, return 403 otherwise 200.

---

Moreover, If you want to redirect to login page when login check is fail, you can use `errorRidirect()`. It call `302 redirect`.

middleware/checkLoginMiddleware.nim
```nim
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
    
proc isLogin*(request: Request):Response =
  try:
    discard hasLoginId(request)
    discard hasLoginToken(request)
  except:
    return errorRedirect("/login")
```
main.nim
```nim
routes:
  get "/index":
    middleware([isLogin(request)])
    route(sample_controller.index())
```