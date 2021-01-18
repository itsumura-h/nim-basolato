Security
===
[back](../../README.md)

Table of Contents

<!--ts-->
   * [Security](#security)
      * [Check in middleware](#check-in-middleware)
         * [CSRF Token](#csrf-token)
      * [Session DB](#session-db)
      * [Auth](#auth)
         * [API](#api)
         * [Sample](#sample)
      * [Cookie](#cookie)
         * [API](#api-1)
         * [Sample](#sample-1)
      * [Session](#session)
         * [API](#api-2)
         * [Sample](#sample-2)

<!-- Added by: root, at: Sun Dec 27 18:23:11 UTC 2020 -->

<!--te-->

## Check in middleware
Basolato check whether value is valid in middleware. `checkCsrfToken()` and `checkSessionId()` are available.  
These procs return `MiddlwareResult` object.

```nim
type MiddlewareResult* = ref object
  isError: bool
  message: string

proc isError*(this:MiddlewareResult):bool =
  return this.isError

proc message*(this:MiddlewareResult):string =
  return this.message
```

### CSRF Token
Basolato can check whether csrf token is valid if request metod is `post`, `put`, `patch`, `delete`.

main.nim
```nim
var routes = newRoutes()
routes.middleware(".*", auth_middleware.checkCsrfTokenMiddleware)
```

app/middlewares/auth_middleware.nim
```nim
proc checkCsrfTokenMiddleware*(r:Request, p:Params) {.async.} =
  let res = await checkCsrfToken(r, p)
  if res.isError:
    raise newException(Error403, res.message)
```

Set `${csrfToken()}` in view.
```nim
<form method="POST">
  $(csrfToken())
  <input type="text" name="name">
  <input type="text" name="password">
  <button type="submit">login</button>
</form>
```

You can overwrite your own custom error handring.
```nim
# If you want to return 403
let res = await checkCsrfToken(r, p)
if res.isError:
  raise newException(Error403, "Error message")

# If you want to redirect login page
let res = await checkCsrfToken(r, p)
if res.isError:
  raise newException(Error302, "/login")
```

## Session DB
You can choose two options to use session, `File` or `Redis`.  
File session uses [flatdb](https://github.com/enthus1ast/flatdb) , a document database like Mongo, inside.


config.nims for file session
```nim
putEnv("SESSION_TYPE", "file")
putEnv("SESSION_DB_PATH", "/your/project/path/session.db") # file path
putEnv("REDIS_PORT", "6379")
putEnv("SESSION_TIME", "20160") # minutes of 2 weeks
```

config.nims for redis session
```nim
putEnv("SESSION_TYPE", "redis")
putEnv("SESSION_DB_PATH", "localhost") # Redis IP address
putEnv("REDIS_PORT", "6379")
putEnv("SESSION_TIME", "20160") # minutes of 2 weeks
```

## Auth
Basolato has Auth system. it conceal inconvenient cookie and session process.

```nim
type Auth* = ref object
  isLogin*:bool
  session*:Session
```

### API
```nim
proc newAuth*(request:Request):Future[Auth] {.async.} =

proc login*(this:Auth) {.async.} =

proc logout*(this:Auth) {.async.} =

proc isLogin*(this:Auth):Future[bool] {.async.} =

proc getToken*(this:Auth):Future[string] {.async.} =

proc set*(this:Auth, key, value:string) {.async.} =

proc some*(this:Auth, key:string):Future[bool] {.async.} =

proc get*(this:Auth, key:string):Future[string] {.async.} =

proc delete*(this:Auth, key:string) {.async.} =

proc destroy*(this:Auth) {.async.} =

proc setFlash*(this:Auth, key, value:string) {.async.} =

proc hasFlash*(this:Auth, key:string):Future[bool] {.async.} =

proc getFlash*(this:Auth):Future[JsonNode] {.async.} =
```

### Sample
login
```nim
proc index(request:Request, params:Params):Future[Response] {.async.} =
  let email = params.getStr("email")
  let password = params.getStr("password")
  let userId = newLoginUsecase().login(email, password)
  let auth = await newAuth(request)
  await auth.login()
  await auth.set("id", $userId)
  return redirect("/")
```

logout
```nim
proc index(request:Request, params:Params):Future[Response] {.async.} =
  let auth = await newAuth(request)
  if await auth.isLogin():
    await auth.logout()
  redirect("/")
```

get from session
```nim
proc index(request:Request, params:Params):Future[Response] {.async.} =
  let auth = await newAuth(request)
  let loginName = await auth.get("login_name")
```

set value in session
```nim
proc index(request:Request, params:Params):Future[Response] {.async.} =
  let name = params.getStr("name")
  let auth = await newAuth(request)
  await auth.set("login_name", name)
  return render("auth")
```

check and get value in session
```nim
proc index(request:Request, params:Params):Future[Response] {.async.} =
  var loginName:string
  let auth = await newAuth(request)
  if await auth.some("login_name"):
    loginName = await auth.get("login_name")
```

delete one key-value pair of session
```nim
proc destroy(request:Request, params:Params):Future[Response] {.async.} =
  let auth = await newAuth(request)
  await auth.delete("login_name")
  return render("auth")
```

destroy all session data
```nim
proc destroy(request:Request, params:Params):Future[Response] {.async.} =
  let auth = await newAuth(request)
  return render("auth")
```

set flash message
```nim
proc store*(request:Request, params:Params):Response =
  let auth = await newAuth(request)
  await auth.setFlash("success", "Welcome to the Sample App!")
  return redirect("/auth")
```

get flash message
```nim
proc show*(this:Controller):Response =
  let auth = await newAuth(request)
  let flash = await auth.getFlash("success")
  return render(showHtml(user, flash))
```

**⚠ In most cases, Session and Cookies should not be used directly, but using Auth is recommended. ⚠**

## Cookie

```nim
type
  CookieData* = ref object
    name: string
    value: string
    expire: string
    sameSite: SameSite
    secure: bool
    httpOnly: bool
    domain: string
    path: string

  Cookie* = ref object
    request: Request
    cookies*: seq[CookieData]
```

### API
```nim
proc newCookie*(request:Request):Cookie =

proc get*(this:Cookie, name:string):string =

proc set*(this:var Cookie, name, value: string, expire:DateTime,
      sameSite: SameSite=Lax, secure = false, httpOnly = false, domain = "",
      path = "/") =

proc set*(this:var Cookie, name, value: string, sameSite: SameSite=Lax,
      secure = false, httpOnly = false, domain = "", path = "/") =

proc updateExpire*(this:var Cookie, name:string, num:int, timeUnit:TimeUnit, path="/") =

proc updateExpire*(this:var Cookie, num:int, time:TimeUnit) =

proc delete*(this:Cookie, key:string, path="/"):Cookie =

proc destroy*(this:Cookie, path="/"):Cookie =

proc setCookie*(response:Response, cookie:Cookie):Response =
```

### How to create cookie for multiple domains
You can define multiple domains for cookie in setting of `config.nims`

config.nims
```nim
putEnv("COOKIE_DOMAINS", "localhost, nim-lang.org, github.com")
```


### Sample
get cookie
```nim
proc index(request:Request, params:Params):Future[Response] {.async.} =
  let val = newCookie(request).get("key")
```

set cookie
```nim
proc store*(request:Request, params:Params):Future[Response] {.async.} =
  let name = params.getStr("name")
  var cookie = newCookie(request)
  cookie.set("name", name)
  return render("with cookie").setCookie(cookie)
```

update cookie expire
```nim
proc store*(request:Request, params:Params):Future[Response] {.async.} =
  var cookie = newCookie(request)
  cookie.updateExpire("name", 5)
  # cookie will be deleted after 5 days from now
  return render("with cookie").setCookie(cookie)
```

delete cookie
```nim
proc index(request:Request, params:Params):Future[Response] {.async.} =
  var cookie = newCookie(request)
  cookie.delete("key")
  return render("with cookie").setCookie(cookie)
```

destroy all cookies
```nim
proc index(request:Request, params:Params):Future[Response] {.async.} =
  var cookie = newCookie(request)
  cookie.destroy()
  return render("with cookie").setCookie(cookie)
```

⚠️ Since cookies are set `Secure` and `HttpOnly` in production environment, they will not be read by JavaScript and can only be used in HTTPS.


## Session
Basolato use [nimAES](https://github.com/jangko/nimAES) as session DB. We have a plan to be able to choose Redis in the future.

If you set `sessionId` in arg of `newSession()`, it return existing session otherwise create new session.

```nim
Session* = ref object
  db: SessionDb
```

### API
```nim
proc newSession*(token=""):Future[Session] {.async.} =
  # If you set valid token, it connect to existing session.
  # If you don't set token, it creates new session.

proc getToken*(this:Session):Future[string] {.async.} =

proc set*(this:Session, key, value:string) {.async.} =

proc some*(this:Session, key:string):Future[bool] {.async.} =

proc get*(this:Session, key:string):Future[string] {.async.} =

proc delete*(this:Session, key:string) {.async.} =

proc destroy*(this:Session) {.async.} =
```

### Sample
get session id
```nim
proc index(request:Request, params:Params):Future[Response] {.async.} =
  let sessionId = newSession().getToken()
```

set value in session
```nim
proc store(request:Request, params:Params):Future[Response] {.async.} =
  let key = request.params["key"]
  let value = this.request.params["value"]
  discard newSession().set(key, value)
```

check and get value in session
```nim
proc index(this:Controller):Future[Response] {.async.} =
  let sessionId = newCookie(this.request).get("session_id")
  let key = this.request.params["key"]
  let session = newSession(sessionId)
  var value:string
  if session.some(key):
    value = session.get(key)
```

delete one key-value pair of session
```nim
proc destroy(this:Controller):Future[Response] {.async.} =
  let sessionId = newCookie(this.request).getToken()
  let key = this.request.params["key"]
  discard newSession(sessionId).delete(key)
```

destroy session
```nim
proc destroy(this:Controller):Future[Response] {.async.} =
  let sessionId = newCookie(this.request).getToken()
  newSession(sessionId).destroy()
```
