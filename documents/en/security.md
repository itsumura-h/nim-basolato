Security
===
[back](../../README.md)

Table of Contents

<!--ts-->
   * [Security](#security)
      * [Check in middleware](#check-in-middleware)
         * [CSRF Token](#csrf-token)
      * [Session DB](#session-db)
      * [Client](#client)
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

<!-- Added by: root, at: Sat Apr  3 12:46:33 UTC 2021 -->

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
putEnv("SESSION_TIME", "20160") # minutes of 2 weeks
```

config.nims for redis session
```nim
putEnv("SESSION_TYPE", "redis")
putEnv("SESSION_DB_PATH", "localhost:6379") # Redis IP address
putEnv("SESSION_TIME", "20160") # minutes of 2 weeks
```

## Client
Basolato has `Client` type. it has functions for Authentication, and Session.

```nim
type Client* = ref object
  session*: Session
```

### API
Creating client instance.
```nim
proc newClient*(request:Request):Future[Client] {.async.} =

proc newClient*(sessionId:string):Future[Client] {.async.} =
```
---
Accessing session db.
```nim
proc set*(self:Client, key, value:string) {.async.} =

proc set*(self:Client, key:string, value:JsonNode) {.async.} =

proc some*(self:Client, key:string):Future[bool] {.async.} =

proc get*(self:Client, key:string):Future[string] {.async.} =

proc delete*(self:Client, key:string) {.async.} =

proc destroy*(self:Client) {.async.} =
```
---
Using for Authentication.
```nim
proc login*(self:Client) {.async.} =

proc isLogin*(self:Client):Future[bool] {.async.} =

proc logout*(self:Client) {.async.} =
```
---
Getting session id which is provided to cookie.
```nim
proc getToken*(self:Client):Future[string] {.async.} =
```
---
Accessing flash data in session db.
```nim
proc setFlash*(self:Client, key, value:string) {.async.} =

proc setFlash*(self:Client, key:string, value:JsonNode) {.async.} =

proc hasFlash*(self:Client, key:string):Future[bool] {.async.} =

proc getFlash*(self:Client):Future[JsonNode] {.async.} =

proc getValidationResult*(self:Client):Future[tuple[params:JsonNode, errors:JsonNode]] {.async.} =
```


### Sample
newClient for MPA(Multi page application)
```nim
proc index(request:Request, params:Params):Future[Response] {.async.} =
  let client = await newClient(request)
```

newClient for API
```nim
proc index(request:Request, params:Params):Future[Response] {.async.} =
  let sessionId = request.headers["x-login-token"]
  let client = await newClient(sessionId)
```

login
```nim
proc index(request:Request, params:Params):Future[Response] {.async.} =
  let email = params.getStr("email")
  let password = params.getStr("password")
  let userId = newLoginUsecase().login(email, password)
  let client = await newClient(request)
  await client.login()
  await client.set("id", $userId)
  return redirect("/")
```

logout
```nim
proc index(request:Request, params:Params):Future[Response] {.async.} =
  let client = await newClient(request)
  if await client.isLogin():
    await client.logout()
  redirect("/")
```

get from session
```nim
proc index(request:Request, params:Params):Future[Response] {.async.} =
  let client = await newClient(request)
  let loginName = await client.get("login_name")
```

set value in session
```nim
proc index(request:Request, params:Params):Future[Response] {.async.} =
  let name = params.getStr("name")
  let client = await newClient(request)
  await client.set("login_name", name)
  return render("auth")
```

check and get value in session
```nim
proc index(request:Request, params:Params):Future[Response] {.async.} =
  var loginName:string
  let client = await newClient(reques)
  if await client.some("login_name"):
    loginName = await client.get("login_name")
```

delete one key-value pair of session
```nim
proc destroy(request:Request, params:Params):Future[Response] {.async.} =
  let client = await newClient(request)
  await client.delete("login_name")
  return render("auth")
```

destroy all session data
```nim
proc destroy(request:Request, params:Params):Future[Response] {.async.} =
  let client = await newClient(request)
  return render("auth")
```

set flash message
```nim
proc store*(request:Request, params:Params):Response =
  let client = await newClient(request)
  await client.setFlash("success", "Welcome to the Sample App!")
  return redirect("/auth")
```

get flash message
```nim
proc show*(self:Controller):Response =
  let client = await newClient(request)
  let flash = await client.getFlash("success")
  let user = newUserUsecase().show()
  return render(showHtml(user, flash))
```

### Anonymous user cookie
In `config.nims`, if you set `true` for `ENABLE_ANONYMOUS_COOKIE`, Basolato automatically creates cookie for every user.  
If you set `false` and you want to create sign in function, you should create it manually in controller.

#### anonymous user enabled

config.nims
```nim
putEnv("ENABLE_ANONYMOUS_COOKIE", "true")
```

controller
```nim
proc signIn*(request:Request, params:Params):Future[Response] {.async.} =
  let email = params.getStr("email")
  let password = params.getStr("password")
  # ..sign in check
  let client = await newClient(request)
  await client.login()
  return redirect("/")
```

#### anonymous user disabled

config.nims
```nim
putEnv("ENABLE_ANONYMOUS_COOKIE", "false")
```

controller
```nim
proc signIn*(request:Request, params:Params):Future[Response] {.async.} =
  let email = params.getStr("email")
  let password = params.getStr("password")
  # ..sign in check
  let client = await newClient(request)
  await client.login()
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
proc newCookie*(request:Request):Cookie =

proc get*(self:Cookie, name:string):string =

proc set*(self:var Cookie, name, value: string, expire:DateTime,
      sameSite: SameSite=Lax, secure = false, httpOnly = true, domain = "",
      path = "/") =

proc set*(self:var Cookie, name, value: string, sameSite: SameSite=Lax,
      secure = false, httpOnly = true, domain = "", path = "/") =

proc updateExpire*(self:var Cookie, name:string, num:int, timeUnit:TimeUnit, path="/") =

proc updateExpire*(self:var Cookie, num:int, time:TimeUnit) =

proc delete*(self:Cookie, key:string, path="/"):Cookie =

proc destroy*(self:Cookie, path="/"):Cookie =

proc setCookie*(response:Response, cookie:Cookie):Response =
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
proc index(request:Request, params:Params):Future[Response] {.async.} =
  let sessionId = newSession().getToken()
```

set value in session
```nim
proc store(request:Request, params:Params):Future[Response] {.async.} =
  let key = request.params["key"]
  let value = self.request.params["value"]
  discard newSession().set(key, value)
```

check and get value in session
```nim
proc index(self:Controller):Future[Response] {.async.} =
  let sessionId = newCookie(self.request).get("session_id")
  let key = self.request.params["key"]
  let session = newSession(sessionId)
  var value:string
  if session.some(key):
    value = session.get(key)
```

delete one key-value pair of session
```nim
proc destroy(self:Controller):Future[Response] {.async.} =
  let sessionId = newCookie(self.request).getToken()
  let key = self.request.params["key"]
  discard newSession(sessionId).delete(key)
```

destroy session
```nim
proc destroy(self:Controller):Future[Response] {.async.} =
  let sessionId = newCookie(self.request).getToken()
  newSession(sessionId).destroy()
```
