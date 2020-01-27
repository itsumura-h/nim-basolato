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
proc index(this:Controller): Response =
  let cookie = genCookie("key", "val", daysForward(5))
  return render("with cookie").setCookie(cookie)
```

get cookie
```nim
proc index(this:Controller): Response =
  let val = this.request.getCookie("key")
```

update cookie expire
```nim
proc index(this:Controller): Response =
  return render("with cookie")
          .updateCookieExpire(this.request, "key", daysForward(5))
```

delete cookie
```nim
proc index(this:Controller): Response =
  return render("with cookie")
          .deleteCookie("key")
```


# Session

create new session
```nim
proc index(this:Controller): Response =
  let session = sessionStart()
  echo session.token

>> 9DF6D313AAADCCDE780AB54EAFF2CC49C130B760
```

create new session with id
```nim
proc index(this:Controller): Response =
  let id = 1
  let session = sessionStart(id)
  echo session.token

>> 9DF6D313AAADCCDE780AB54EAFF2CC49C130B760
```

add value in session
```nim
proc index(this:Controller): Response =
  let session = sessionStart()
                  .add("login_name", "user1")
```

# Auth