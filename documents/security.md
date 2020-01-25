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
  login*: Login

# constructor
proc newPostsController*(request:Request): PostsController =
  return PostsController(
    request: request,
    login: initLogin(request)
  )

# pass login data to view
proc create*(this:PostsController): Response =
  return render(createHtml(this.login))
```

## View
Set `$(csrfToken(login))` in view.
```nim
proc createHtml*(login:Login):string = tmpli html("""
<form method="post">
  $(csrfToken(login))
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