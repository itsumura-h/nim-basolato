Security
===
[back](../README.md)

# CSRF Token
When you run application as web page, Basolato check whether csrf token is valid if request metod is `post`.

## Routing
When to pass request to controller, set login field in constructor.
```nim
get "/posts/create": route(newPostsController(request).create())
post "/posts/create": route(newPostsController(request).store())
```

## Controller
Then, pass login field to view.

```nim
# DI
type PostsController* = ref object
  request*: Request
  auth*: Auth

# constructor
proc newPostsController*(request:Request): PostsController =
  return PostsController(
    request: request,
    auth: initAuth(request)
  )

# pass login data to view
proc create*(this:PostsController): Response =
  return render(createHtml(this.auth))
```

## View
Set `$(csrfToken(auth))` in view.
```nim
proc createHtml*(auth:Auth):string = tmpli html("""
<form method="post">
  $(csrfToken(auth))
  .
  .
</form>
""")
```

## Middleware
When Basolato recieve post request, csrf token check is run in `framework_middleware`.

```nim
# routing
routes:
  before: framework

# middleware
template framework*() =
  checkCsrfToken(request)
```
If token is invalid, return `500`.

You can overwrite your own custom error handring.
```nim
# If you want to return 403
checkCsrfToken(request Error403, getCurrentMsg())

# If you want to redirect login page
checkCsrfToken(request Error302, "/login")
```

# Cookie

create new cookie
```nim
# example
proc index(this:Controller): Response =
  let cookie = genCookie("key", "val", daysForward(5))
  return render("with cookie").setCookie(cookie)
```
```nim
# API
proc genCookie*(name, value: string, expires="",
                    sameSite: SameSite=Lax, secure = false,
                    httpOnly = false, domain = "", path = ""): string =

proc genCookie*(name, value: string, expires: DateTime,
                    sameSite: SameSite=Lax, secure = false,
                    httpOnly = false, domain = "", path = ""): string =

proc setCookie*(response:Response, cookie:string): Response =

proc daysForward*(days: int): DateTime =
```

get cookie
```nim
# example
proc index(this:Controller): Response =
  let val = this.request.getCookie("key")
```
```nim
# API
proc getCookie*(request:Request, key:string): string =
```

update cookie expire
```nim
# example
proc index(this:Controller): Response =
  return render("with cookie")
          .updateCookieExpire(this.request, "key", 5)
```
```nim
# API
proc updateCookieExpire*(response:Response, request:Request, key:string, days:int): Response =
```

delete cookie
```nim
# example
proc index(this:Controller): Response =
  return render("with cookie")
          .deleteCookie("key")
```
```nim
# API
proc deleteCookie*(response:Response, key:string): Response =
```


# Session
```nim
type Session* = ref object
  token*: string
  cookie*: tuple[key, val:string]
```


create new session
```nim
# example
proc index(this:Controller): Response =
  let session = sessionStart()
  echo session.token

>> 9DF6D313AAADCCDE780AB54EAFF2CC49C130B760
```
```nim
proc sessionStart*(): Session =
```


create new session which relate to id
```nim
# example
proc index(this:Controller): Response =
  let id = 1
  let session = sessionStart(id)
  echo session.token

>> 9DF6D313AAADCCDE780AB54EAFF2CC49C130B760
```
```nim
# API
proc sessionStart*(uid:int):Session =
```

add value in session
```nim
# example
proc index(this:Controller): Response =
  let session = sessionStart()
                  .add("login_name", "user1")
```
```nim
# API
proc add*(this:Session, key:string, val:string):Session =
```

# Auth
```nim
type Auth* = ref object
  isLogin*: bool
  token*: string
  uid*: string
  info*: Table[string, string]
```

create auth instance in constructor
```nim
# example
type Controller = ref object
  request: Request
  auth: Auth

proc newController*(request:Request): Controller =
  return Controller(
    request: request,
    auth: initAuth(request)
  )
```
```nim
# API
proc initAuth*(request:Request): Auth =
```

destroy auth status and related session
```nim
# example
proc destroy*(this: Controller): Response =
  this.auth.destroy()
  return redirect("/").deleteCookie("token")
```
```nim
# API
proc destroy*(this:Auth) =
```

## dev info
### Not loged in
- cookie:
  - csrftoken: 1 year
    - 403 CSRF Error
- input:
  - csrfmiddlewaretoken
    - 403 CSRF Error

### logged in
- cookie:
  - csrftoken: 1 year. update all access
    - 403 CSRF Error
  - sessionid: 2 weeks.
    - 302 redirect login page
- input:
  - csrfmiddlewaretoken
    - 403 CSRF Error
