Context, Cookie, Session
===
[back](../../README.md)

Table of Contents

<!--ts-->
* [Context, Cookie, Session](#context-cookie-session)
   * [Check in middleware](#check-in-middleware)
      * [CSRF Token](#csrf-token)
   * [Session DB](#session-db)
   * [Context](#context)
      * [API](#api)
      * [Sample](#sample)
      * [Anonymous user cookie](#anonymous-user-cookie)
         * [anonymous user enabled](#anonymous-user-enabled)
         * [anonymous user disabled](#anonymous-user-disabled)
      * [How to create cookie for multiple domains](#how-to-create-cookie-for-multiple-domains)
   * [Cookie](#cookie)
      * [API](#api-1)
      * [Sample](#sample-1)
   * [Session](#session)
      * [API](#api-2)
      * [Sample](#sample-2)

<!-- Created by https://github.com/ekalinin/github-markdown-toc -->
<!-- Added by: root, at: Fri Dec 22 21:21:35 UTC 2023 -->

<!--te-->

## Check in middleware
Basolato check whether value is valid in middleware. `checkCsrfToken()` and `checkSessionId()` are available.  
These procs return `MiddlwareResult` object.

```nim
type MiddlewareResult* = ref object
  isError: bool
  message: string

proc isError*(self:MiddlewareResult):bool =
  return self.isError

proc message*(self:MiddlewareResult):string =
  return self.message
```

### CSRF Token
Basolato can check whether csrf token is valid if request metod is `post`, `put`, `patch`, `delete`.

main.nim
```nim
var routes = Routes.new()
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

config.nims for file session
```nim
putEnv("SESSION_TYPE", "file")
putEnv("SESSION_DB_PATH", "/your/project/path/session.db") # file path
```

.env
```env
SESSION_TIME=20160 # minutes of 2 weeks
```

config.nims for redis session
```nim
putEnv("SESSION_TYPE", "redis")
putEnv("SESSION_DB_PATH", "localhost:6379") # Redis IP address
```

.env
```env
SESSION_TIME=20160 # minutes of 2 weeks
```

## Context
Basolato has `Context` type. it has functions for Authentication, and Session.

```nim
type Context* = ref object
  request: Request
  session*: Session
```

### API
Creating context instance.
```nim
proc new*(typ:type Context, context:Context, isCreateNew=false):Future[Context]{.async.}
```
---
Accessing session db.
```nim
proc set*(self:Context, key, value:string) {.async.} =

proc set*(self:Context, key:string, value:JsonNode) {.async.} =

proc some*(self:Context, key:string):Future[bool] {.async.} =

proc get*(self:Context, key:string):Future[string] {.async.} =

proc delete*(self:Context, key:string) {.async.} =

proc destroy*(self:Context) {.async.} =
```
---
Using for Authentication.
```nim
proc login*(self:Context) {.async.} =

proc isLogin*(self:Context):Future[bool] {.async.} =

proc logout*(self:Context) {.async.} =
```
---
Getting session id which is provided to cookie.
```nim
proc getToken*(self:Context):Future[string] {.async.} =
```
---
Accessing flash data in session db.
```nim
proc setFlash*(self:Context, key, value:string) {.async.} =

proc setFlash*(self:Context, key:string, value:JsonNode) {.async.} =

proc hasFlash*(self:Context, key:string):Future[bool] {.async.} =

proc getFlash*(self:Context):Future[JsonNode] {.async.} =

proc getValidationResult*(self:Context):Future[tuple[params:JsonNode, errors:JsonNode]] {.async.} =
```


### Sample
login
```nim
proc index(context:Context, params:Params):Future[Response] {.async.} =
  let email = params.getStr("email")
  let password = params.getStr("password")
  let userId = newLoginUsecase().login(email, password)
  await context.login()
  await context.set("id", $userId)
  return redirect("/")
```

logout
```nim
proc index(context:Context, params:Params):Future[Response] {.async.} =
  if await context.isLogin():
    await context.logout()
  redirect("/")
```

get from session
```nim
proc index(context:Context, params:Params):Future[Response] {.async.} =
  let loginName = await context.get("login_name")
```

set value in session
```nim
proc index(context:Context, params:Params):Future[Response] {.async.} =
  let name = params.getStr("name")
  await context.set("login_name", name)
  return render("auth")
```

check and get value in session
```nim
proc index(context:Context, params:Params):Future[Response] {.async.} =
  var loginName:string
  if await context.some("login_name"):
    loginName = await client.get("login_name")
```

delete one key-value pair of session
```nim
proc destroy(context:Context, params:Params):Future[Response] {.async.} =
  await context.delete("login_name")
  return render("auth")
```

destroy all session data
```nim
proc destroy(context:Context, params:Params):Future[Response] {.async.} =
  await context.destroy()
  return render("auth")
```

set flash message
```nim
proc store*(context:Context, params:Params):Response =
  await context.setFlash("success", "Welcome to the Sample App!")
  return redirect("/auth")
```

get flash message
```nim
proc show*(context:Context):Response =
  let flash = await context.getFlash("success")
  let user = UserUsecase.new().show()
  return render(showHtml(user, flash))
```

### Anonymous user cookie
In `.env`, if you set `true` for `ENABLE_ANONYMOUS_COOKIE`, Basolato automatically creates cookie for every user.  
If you set `false` and you want to create sign in function, you should create it manually in controller.

#### anonymous user enabled

.env
```env
ENABLE_ANONYMOUS_COOKIE=true
```

controller
```nim
proc signIn*(context:Context, params:Params):Future[Response] {.async.} =
  let email = params.getStr("email")
  let password = params.getStr("password")
  # ..sign in check
  await context.login()
  return redirect("/")
```

#### anonymous user disabled

config.nims
```nim
putEnv("ENABLE_ANONYMOUS_COOKIE", "false")
```

controller
```nim
proc signIn*(context:Context, params:Params):Future[Response] {.async.} =
  let email = params.getStr("email")
  let password = params.getStr("password")
  # ..sign in check
  await context.login()
  return await redirect("/").setCookie(client)
```

### How to create cookie for multiple domains
You can define multiple domains for cookie in setting of `config.nims`

config.nims
```nim
putEnv("COOKIE_DOMAINS", "nim-lang.org, github.com")
```
`Chrome` doesn't allow domain of cookie `localhost`, and therefore if you want to create cookie for localhost, please specify setting like this.

```nim
putEnv("COOKIE_DOMAINS", ", nim-lang.org, github.com")
```


**⚠ In most cases, Session and Cookies should not be used directly, but using Client is recommended. ⚠**

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
proc new*(_:type Cookie, context:Context):Cookie =

proc get*(self:Cookie, name:string):string =

proc set*(self:var Cookie, name, value: string, expire:DateTime,
      sameSite: SameSite=Lax, secure = false, httpOnly = true, domain = "",
      path = "/") =

proc set*(self:var Cookie, name, value: string, sameSite: SameSite=Lax,
      secure = false, httpOnly = true, domain = "", path = "/") =

proc delete*(self:Cookie, key:string, path="/"):Cookie =

proc destroy*(self:Cookie, path="/"):Cookie =

proc setCookie*(response:Response, cookie:Cookie):Response =
```

### Sample
get cookie
```nim
proc index(context:Context, params:Params):Future[Response] {.async.} =
  let val = Cookie.new(context.request).get("key")
```

set cookie
```nim
proc store*(context:Context, params:Params):Future[Response] {.async.} =
  let name = params.getStr("name")
  var cookie = Cookie.new(context.request)
  cookie.set("name", name)
  return render("with cookie").setCookie(cookie)
```

update cookie expire
```nim
proc store*(context:Context, params:Params):Future[Response] {.async.} =
  var cookie = Cookie.new(context.request)
  let name = cookie.get("name")
  # cookie will be deleted after 5 days from now
  cookie.set("name", name, expire=timeForward(5, Days))
  return render("with cookie").setCookie(cookie)
```

delete cookie
```nim
proc index(context:Context, params:Params):Future[Response] {.async.} =
  var cookie = Cookie.new(context.request)
  cookie.delete("key")
  return render("with cookie").setCookie(cookie)
```

destroy all cookies
```nim
proc index(context:Context, params:Params):Future[Response] {.async.} =
  var cookie = Cookie.new(context.request)
  cookie.destroy()
  return render("with cookie").setCookie(cookie)
```

⚠️ Since cookies are set `Secure` and `HttpOnly` in production environment, they will not be read by JavaScript and can only be used in HTTPS.


## Session
Basolato use json file as file session DB.

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

proc getToken*(self:Session):Future[string] {.async.} =

proc set*(self:Session, key, value:string) {.async.} =

proc some*(self:Session, key:string):Future[bool] {.async.} =

proc get*(self:Session, key:string):Future[string] {.async.} =

proc delete*(self:Session, key:string) {.async.} =

proc destroy*(self:Session) {.async.} =
```

### Sample
get session id
```nim
proc index(context:Context, params:Params):Future[Response] {.async.} =
  let sessionId = newSession().getToken()
```

set value in session
```nim
proc store(context:Context, params:Params):Future[Response] {.async.} =
  let key = params.getStr("key")
  let value = params.getStr("value")
  discard newSession().set(key, value)
```

check and get value in session
```nim
proc index(context:Context, params:Params):Future[Response] {.async.} =
  let sessionId = Cookie.new(context.request).get("session_id")
  let key = params.getStr("key")
  let session = newSession(sessionId)
  var value:string
  if session.some(key):
    value = session.get(key)
```

delete one key-value pair of session
```nim
proc destroy(context:Context, params:Params):Future[Response] {.async.} =
  let sessionId = Cookie.new(context.request).getToken()
  let key = params.getStr("key")
  discard newSession(sessionId).delete(key)
```

destroy session
```nim
proc destroy(context:Context, params:Params):Future[Response] {.async.} =
  let sessionId = Cookie.new(context.request).getToken()
  newSession(sessionId).destroy()
```
