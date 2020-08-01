Middleware
===
[back](../README.md)

Table of Contents

<!--ts-->
   * [Middleware](#middleware)
      * [Routing middleware](#routing-middleware)
      * [Controller middleware](#controller-middleware)
      * [How to update responce in middleware](#how-to-update-responce-in-middleware)

<!-- Added by: root, at: Sat Aug  1 12:12:14 UTC 2020 -->

<!--te-->

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

from middleware/middlewares import loginCheck, someMiddleware

router api:
  get "/api1":
    route(render("api1"))
  get "/api2":
    route(render("api2"))

routes:
  before re"/api.*":
    middleware(hasLoginId(request), hasLoginToken(request))
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
    middleware(isLogin(request))
    route(sample_controller.index())
```

## Controller middleware
If you want to run middleware in controller, set middleware in contructor of controller.

app/middlewares/controller_middleware.nim
```nim
import httpcore
import basolato/middleware

proc hasSessionId*(request:Request) =
  if not request.headers().hasKey("session_id"):
    raise newException(Error302, "/login")
```

app/controllers/todo_controller.nim
```nim
import basolato/controller
# import middleware
import ../middlewares/controller_middlewares


type TodoController* = ref object of Controller

proc newTodoController*(request:Request):TodoController =
  # run middleware here
  hasSessionId(request)
  return TodoController.newController(request)
```

main.nim
```nim
import app/controllers/todo_controller
import app/controllers/login_controller


routes:
  # Framework
  error Http404: http404Route
  error Exception: exceptionRoute
  before: framework

  get "/": route(newTodoController(request).index())
  get "/login": route(newLoginController(request).index())
```



## How to update responce in middleware
The following sample is to set session cookie if `session_id` is not in cookies.

```nim
# main.nim
import middlewares/middlewares_always_create_cookie_middleware

routes:
  get "/": newSomeController(request).index()
  after: always_create_cookie
```

```nim
# middlewares_always_create_cookie_middleware.nim
import basolato/response

template always_create_cookie*() =
  var response = response(result)
  if not request.cookies.hasKey("session_id"):
    let auth = newAuth()
    response = response.setAuth(auth)
  route(response)
```

`responce(result)` return `Responce` type object.  
And, `route(response)` 
