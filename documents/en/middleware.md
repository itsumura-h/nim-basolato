Middleware
===
[back](../../README.md)

Table of Contents

<!--ts-->
   * [Middleware](#middleware)
      * [Routing middleware](#routing-middleware)

<!-- Added by: root, at: Sun Dec 27 18:20:43 UTC 2020 -->

<!--te-->

## API
```nim
proc middleware*(
  this:var Routes,
  path:Regex,
  action:proc(r:Request, p:Params):Future[Response]
) =

proc middleware*(
  this:var Routes,
  httpMethods:seq[HttpMethod],
  path:Regex,
  action:proc(r:Request, p:Params):Future[Response]
) =
```

## Sample
You can run middleware methods before calling controller.  
In following example, `checkCsrfTokenMiddleware()` and `checkSessionIdMiddleware()` definded in `app/middleware/auth_middlware.nim` are called

main.nim
```nim
import re
import basolato
import app/middlewares/auth_middleware

var routes = newRoutes()
routes.middleware(re".*", auth_middleware.checkLoginIdMiddleware)
serve(routes)
```

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

If `X-login-id` or `X-login-token` are missing in request header, return 403 otherwise 200.

---

If you want to redirect to login page when login check is fail, you can use `ErrorRedirect`. It calls `Error 302`.

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

---

As in CORS, if you want to return a response made by the middleware to the client instead of the controller, you can set an argument to the `next` proc.  
In following example, `setCorsMiddleware` run only in `OPTIONS` requests.

main.nim
```nim
var routes = newRoutes()
routes.middleware(@[HttpOptions], re"/api/.*", cors_middleware.setCorsMiddleware)
```

app/middleware/cors_middlware.nim
```nim
proc setCorsMiddleware*(r:Request, p:Params):Future[Response] {.async.} =
  let headers = corsHeader() & secureHeader()
  return next(status=Http204, headers=headers)
```