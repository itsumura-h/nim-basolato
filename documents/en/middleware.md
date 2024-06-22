Middleware
===
[back](../../README.md)

Table of Contents

<!--ts-->


<!-- Created by https://github.com/ekalinin/github-markdown-toc -->
<!-- Added by: root, at: Sat Jun 22 10:31:40 UTC 2024 -->

<!--te-->

## API
```nim
proc middleware*(
  self:var Routes,
  path:Regex,
  action:proc(r:Request, p:Params):Future[Response]
) =

proc middleware*(
  self:var Routes,
  httpMethods:seq[HttpMethod],
  path:Regex,
  action:proc(r:Request, p:Params):Future[Response]
) =

proc next*(status:HttpCode=HttpCode(200), body="", headers:Headers=newHeaders()):Response =
```

## Sample
You can run middleware methods before calling controller.  
In following example, `checkCsrfTokenMiddleware()` and `checkSessionIdMiddleware()` definded in `app/middleware/auth_middlware.nim` are called

main.nim
```nim
import basolato
import app/middlewares/auth_middleware


let ROUTES = @[
  Route.get("/", welcome_rontroller.index)
    .middleware(auth_middleware.checkLoginIdMiddleware)
]

serve(routes)
```

app/middleware/auth_middlware.nim
```nim
import asyncdispatch
import basolato/middleware


proc checkLoginId*(c:Context, p:Params):Future[Response] {.async.} =
  if not c.request.headers.hasKey("X-login-id"):
    return render(Http403, "X-login-id is missing in request header")

  if not c.request.headers.hasKey("X-login-token"):
    return render(Http403, "X-login-token is missing in request header")

  return next()
```

If `X-login-id` or `X-login-token` are missing in request header, return 403 otherwise 200.

---

If you want to redirect the user to the login page when the login check fails, use `errorRedirect`. This will call `HTTP 303`.

app/middleware/auth_middlware.nim
```nim
import basolato/middleware

proc checkLoginId*(c:Context, p:Params):Future[Response] {.async.} =
  if not c.request.headers.hasKey("X-login-id"):
    return errorRedirect("/login")

  if not c.request.headers.hasKey("X-login-token"):
    return errorRedirect("/login")

  return next()
```

---

As in CORS, if you want to return a response made by the middleware to the client instead of the controller, you can set an argument to the `next` proc.  
In following example, `setCorsMiddleware` run only in `OPTIONS` requests.

main.nim
```nim
let ROUTES = @[
  Route.put("/api/user/{id:int}", user_controller.update)
    .middleware(cors_middleware.setCorsMiddleware),
]
```

app/middleware/cors_middlware.nim
```nim
proc setCorsMiddleware*(c:Context, p:Params):Future[Response] {.async.} =
  if c.request.httpMethod == HttpOption:
    let headers = corsHeader() & secureHeader()
    return next(status=Http204, headers=headers)
```
