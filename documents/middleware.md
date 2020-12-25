Middleware
===
[back](../README.md)

Table of Contents

<!--ts-->
   * [Middleware](#middleware)
      * [Routing middleware](#routing-middleware)

<!-- Added by: root, at: Fri Dec 25 17:30:30 UTC 2020 -->

<!--te-->

## Routing middleware
You can run middleware methods before calling controller.  
In following example, `checkCsrfTokenMiddleware()` and `checkAuthTokenMiddleware()` definded in `app/middleware/auth_middlware.nim` are called

app/middleware/auth_middlware.nim
```nim
import basolato/middleware

proc checkLoginId(r:Request):Check =
  result = Check(status:true)
  if not r.headers.hasKey("X-login-id"):
    result = Check(
      status:false,
      msg: "X-login-id is missing in request header"
    )

proc checkLoginIdMiddleware*(r:Request, p:Params) =
  checkLoginId(r).catch(Error403)


proc checkLoginToken(r:Request):Check =
  result = Check(status:true)
  if not r.headers.hasKey("X-login-token"):
    result = Check(
      status:false,
      msg: "X-login-token is missing in request header"
    )

proc checkLoginTokenMiddleware*(r:Request) =
  checkAuthToken(r).catch(Error403)
```

main.nim
```nim
import basolato
import app/middlewares/auth_middleware

var routes = newRoutes()
routes.middleware(".*", auth_middleware.checkLoginIdMiddleware)
routes.middleware(".*", auth_middleware.checkLoginTokenMiddleware)
serve(routes)
```

If `X-login-id` or `X-login-token` are missing in request header, return 403 otherwise 200.

---

Moreover, If you want to redirect to login page when login check is fail, you can use `ErrorRedirect`. It calls `Error 302`.

app/middleware/auth_middlware.nim
```nim
import basolato/middleware

proc checkLogin(r:Request):Check =
  result = Check(status:true)
  let auth = newAuth(r)
  if not auth.isLogin():
    result = Check(status:false)

proc checkLoginMiddleware*(r:Request, p:Params) =
  checkLogin(r).catch(ErrorRedirect, "/login")
```
