Security
===
[back](../README.md)

# CSRF Token
Basolato can check whether csrf token is valid if request metod is `post`, `put`, `patch`, `delete`.

### View
Set `$(csrfToken())` in view.
```nim
import basolato/view

proc createHtml*():string = tmpli html("""
<form method="post">
  $(csrfToken())
  .
  .
</form>
""")
```

If `checkCsrfToken(request)` is in `template framework()`, csrf check is available.

middleware/framework_middleware.nim
```nim
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

proc set*(this:Cookie, name, value: string, expire:DateTime,
      sameSite: SameSite=Lax, secure = false, httpOnly = false, domain = "",
      path = "/"):Cookie =

proc set*(this:Cookie, name, value: string, sameSite: SameSite=Lax,
      secure = false, httpOnly = false, domain = "", path = "/"):Cookie =

proc updateExpire*(this:Cookie, name:string, days:int, path="/"):Cookie =

proc delete*(this:Cookie, key:string, path="/"):Cookie =

proc destroy*(this:Cookie, path="/"):Cookie =

proc setCookie*(response:Response, cookie:Cookie):Response =
```

get cookie
```nim
proc index(this:Controller): Response =
  let val = newCookie(this.request).get("key")
```

set cookie
```nim
proc store*(this:Controller): Response =
  let name = this.request.params["name"]
  let cookie = newCookie(this.request)
                .set("name", name)
  return render("with cookie").setCookie(cookie)
```

update cookie expire
```nim
proc store*(this:Controller): Response =
  let cookie = newCookie(this.request)
                .updateExpire("name", 5)
                # cookie will be deleted 5 days from now
  return render("with cookie").setCookie(cookie)
```

delete cookie
```nim
proc index(this:Controller): Response =
  let cookie = newCookie(this.request)
                .delete("key")
  return render("with cookie").setCookie(cookie)
```

destroy all cookies
```nim
proc index(this:Controller): Response =
  let cookie = newCookie(this.request)
                .destroy()
  return render("with cookie").setCookie(cookie)
```


# Session
Basolato use [nimAES](https://github.com/jangko/nimAES) as session DB. We have a plan to be able to choose Redis in the future.

If you set `sessionId` in arg of `newSession()`, it return existing session otherwise create new session.

```nim
type 
  SessionType* = enum
    File
    Redis # Not work now

  Session* = ref object
    db: SessionDb
```

API
```nim
proc newSession*(token="", typ:SessionType=File):Session =

proc db*(this:Session):SessionDb =

proc getToken*(this:Session):string =

proc get*(this:Session, key:string):string =

proc set*(this:Session, key, value:string):Session =

proc delete*(this:Session, key:string): Session =

proc destroy*(this:Session) =
```

get session id
```nim
proc index(this:Controller): Response =
  let sessionId = newCookie().getToken()
```

get value in session
```nim
proc index(this:Controller): Response =
  let sessionId = newCookie(request).get("session_id")
  let key = this.request.params["key"]
  let value = newSession(sessionId).get(key)
```

set value to session
```nim
proc store(this:Controller): Response =
  let key = this.request.params["key"]
  let value = this.request.params["value"]
  discard newSession().set(key, value)
```

delete one key-value pair of session
```nim
proc destroy(this:Controller): Response =
  let sessionId = newCookie().getToken()
  let key = this.request.params["key"]
  discard newSession(sessionId).delete(key)
```

destroy session
```nim
proc destroy(this:Controller): Response =
  let sessionId = newCookie().getToken()
  newSession(sessionId).destroy()
```


# Auth
```nim
type Auth* = ref object
  isLogin*:bool
  session*:Session
```

API
```nim
proc newAuth*(request:Request):Auth =

proc newAuth*():Auth =

proc isLogin*(this:Auth):bool =

proc getId*(this:Auth):string =

proc get*(this:Auth, key:string):string =

proc set*(this:Auth, key, value:string):Auth =

proc delete*(this:Auth, key:string):AUth =

proc destroy*(this:Auth) =
```