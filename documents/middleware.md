Middleware
===
[back](../README.md)

Table of Contents

<!--ts-->
   * [Middleware](#middleware)
      * [Routing middleware](#routing-middleware)

<!-- Added by: root, at: Sun Dec 27 18:20:43 UTC 2020 -->

<!--te-->

## Routing middleware
You can run middleware methods before calling controller.  
In following example, `checkCsrfTokenMiddleware()` and `checkAuthTokenMiddleware()` definded in `app/middleware/auth_middlware.nim` are called

app/middleware/auth_middlware.nim
```nim
import asyncdispatch
import basolato/middleware


proc checkLoginId*(r:Request, p:Params):Future[Response] {.async.} =
  if not r.headers.hasKey("X-login-id"):
    raise newException(Error403, "X-login-id is missing in request header")

  if not r.headers.hasKey("X-login-token"):
    raise newException(Error403, "X-login-token is missing in request header")

  return next()
```

main.nim
```nim
import re
import basolato
import app/middlewares/auth_middleware

var routes = newRoutes()
routes.middleware(re".*", auth_middleware.checkLoginIdMiddleware)
serve(routes)
```

If `X-login-id` or `X-login-token` are missing in request header, return 403 otherwise 200.

---

Moreover, If you want to redirect to login page when login check is fail, you can use `ErrorRedirect`. It calls `Error 302`.

app/middleware/auth_middlware.nim
```nim
import basolato/middleware

proc checkLoginId*(r:Request, p:Params):Future[Response] {.async.} =
  if not r.headers.hasKey("X-login-id"):
    raise newException(ErrorRedirect, "/login")

  if not r.headers.hasKey("X-login-token"):
    raise newException(ErrorRedirect, "/login")
  return next()
```
