セキュリティ
===
[戻る](../../README.md)

コンテンツ

<!--ts-->
   * [セキュリティ](#セキュリティ)
      * [ミドルウェア内でのチェック](#ミドルウェア内でのチェック)
         * [CSRFトークン](#csrfトークン)
      * [セッションDB](#セッションdb)
      * [Client](#client)
         * [API](#api)
         * [サンプル](#サンプル)
         * [匿名ユーザーへのクッキー](#匿名ユーザーへのクッキー)
            * [匿名ユーザーが有効な時](#匿名ユーザーが有効な時)
            * [匿名ユーザーが無効な時](#匿名ユーザーが無効な時)
         * [複数のドメインにクッキーを作る時](#複数のドメインにクッキーを作る時)
      * [クッキー](#クッキー)
         * [API](#api-1)
         * [サンプル](#サンプル-1)
      * [セッション](#セッション)
         * [API](#api-2)
         * [サンプル](#サンプル-2)

<!-- Added by: root, at: Mon Apr 19 03:32:47 UTC 2021 -->

<!--te-->

## ミドルウェア内でのチェック
Basolatoはミドルウェアで値が有効かどうかをチェックします。checkCsrfToken()とcheckSessionId()があります。  
これらの関数は `MiddlwareResult` オブジェクトを返します。

```nim
type MiddlewareResult* = ref object
  isError: bool
  message: string

proc isError*(self:MiddlewareResult):bool =
  return self.isError

proc message*(self:MiddlewareResult):string =
  return self.message
```

### CSRFトークン
Basolatoは、リクエストメソッドが `post`, `put`, `patch`, `delete` の場合に、csrfトークンが有効かどうかをチェックすることができます。

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

エラーが起きた時の処理を上書きすることができます。
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

## セッションDB
セッションには`File`か`Redis`が使えます。
ファイルセッションはMongoに似たドキュメントDBの[flatdb](https://github.com/enthus1ast/flatdb)を使っています。

ファイルセッションの時

config.nims
```nim
putEnv("SESSION_TYPE", "file")
```
.env
```env
SESSION_DB_PATH="/your/project/path/session.db" # db file path
SESSION_TIME=20160
```

Redisセッションの時

config.nims
```nim
putEnv("SESSION_TYPE", "redis")
```

.env
```env
SESSION_DB_PATH="localhost:6379" # Redis IP address
SESSION_TIME=20160
```

## Client
Basolatoは認証とセッションを内包した`Client`を持っています。

```nim
type Client* = ref object
  session*: Session
```

### API
インスタンス作成
```nim
proc newClient*(request:Request):Future[Client] {.async.} =

proc newClient*(sessionId:string):Future[Client] {.async.} =
```
---
セッションDBへのアクセス
```nim
proc set*(self:Client, key, value:string) {.async.} =

proc set*(self:Client, key:string, value:JsonNode) {.async.} =

proc some*(self:Client, key:string):Future[bool] {.async.} =

proc get*(self:Client, key:string):Future[string] {.async.} =

proc delete*(self:Client, key:string) {.async.} =

proc destroy*(self:Client) {.async.} =
```
---
認証
```nim
proc login*(self:Client) {.async.} =

proc isLogin*(self:Client):Future[bool] {.async.} =

proc logout*(self:Client) {.async.} =
```
---
クッキーから送られたセッションIDの取得
```nim
proc getToken*(self:Client):Future[string] {.async.} =
```
---
セッションDBのフラッシュデータへのアクセス
```nim
proc setFlash*(self:Client, key, value:string) {.async.} =

proc setFlash*(self:Client, key:string, value:JsonNode) {.async.} =

proc hasFlash*(self:Client, key:string):Future[bool] {.async.} =

proc getFlash*(self:Client):Future[JsonNode] {.async.} =

proc getValidationResult*(self:Client):Future[tuple[params:JsonNode, errors:JsonNode]] {.async.} =
```


### サンプル
MPA(Multi page application)の時のインスタンス作成
```nim
proc index(request:Request, params:Params):Future[Response] {.async.} =
  let client = await newClient(request)
```

APIの時のインスタンス作成
```nim
proc index(request:Request, params:Params):Future[Response] {.async.} =
  let sessionId = request.headers["x-login-token"]
  let client = await newClient(sessionId)
```

ログイン
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

ログアウト
```nim
proc index(request:Request, params:Params):Future[Response] {.async.} =
  let client = await newClient(request)
  if await client.isLogin():
    await client.logout()
  redirect("/")
```

セッションから値を取得する
```nim
proc index(request:Request, params:Params):Future[Response] {.async.} =
  let client = await newClient(request)
  let loginName = await client.get("login_name")
```

セッションに値を保存する
```nim
proc index(request:Request, params:Params):Future[Response] {.async.} =
  let name = params.getStr("name")
  let client = await newClient(request)
  await client.set("login_name", name)
  return render("auth")
```

セッションに値が存在するかチェックして取得する
```nim
proc index(request:Request, params:Params):Future[Response] {.async.} =
  var loginName:string
  let client = await newClient(reques)
  if await client.some("login_name"):
    loginName = await client.get("login_name")
```

セッションの1つの値を削除する
```nim
proc destroy(request:Request, params:Params):Future[Response] {.async.} =
  let client = await newClient(request)
  await client.delete("login_name")
  return render("auth")
```

クライアントに紐付いた全てのセッションデータを削除する
```nim
proc destroy(request:Request, params:Params):Future[Response] {.async.} =
  let client = await newClient(request)
  return render("auth")
```

フラッシュメッセージを保存する
```nim
proc store*(request:Request, params:Params):Response =
  let client = await newClient(request)
  await client.setFlash("success", "Welcome to the Sample App!")
  return redirect("/auth")
```

フラッシュメッセージを取得する
```nim
proc show*(self:Controller):Response =
  let client = await newClient(request)
  let flash = await client.getFlash("success")
  let user = newUserUsecase().show()
  return render(showHtml(user, flash))
```

### 匿名ユーザーへのクッキー
`.env`の`ENABLE_ANONYMOUS_COOKIE`に`true`を設定すると、Basolatoは全てのクライアントに自動的にクッキーを発行します。
`false`を設定しかつログイン機能を有効にしたい場合は、自作してください。

#### 匿名ユーザーが有効な時

.env
```env
ENABLE_ANONYMOUS_COOKIE=true
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

#### 匿名ユーザーが無効な時

.env
```env
ENABLE_ANONYMOUS_COOKIE=false
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

### 複数のドメインにクッキーを作る時
`.env`の設定で、クッキーのドメインを複数定義することができます。

.env
```env
COOKIE_DOMAINS="nim-lang.org, github.com"
```
`Google Chrome`はクッキーのドメイン「localhost」を許可していないので、localhost用のクッキーを作成したい場合は、以下のように設定してください。

```nim
COOKIE_DOMAINS=", nim-lang.org, github.com"
```

**⚠ ほとんどの場合、SessionとCookiesは直接使用すべきではなく、Clientを使用するべきです。 ⚠**

## クッキー

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
      sameSite: SameSite=Lax, secure = false, httpOnly = false, domain = "",
      path = "/") =

proc set*(self:var Cookie, name, value: string, sameSite: SameSite=Lax,
      secure = false, httpOnly = false, domain = "", path = "/") =

proc updateExpire*(self:var Cookie, name:string, num:int, timeUnit:TimeUnit, path="/") =

proc updateExpire*(self:var Cookie, num:int, time:TimeUnit) =

proc delete*(self:Cookie, key:string, path="/"):Cookie =

proc destroy*(self:Cookie, path="/"):Cookie =

proc setCookie*(response:Response, cookie:Cookie):Response =
```

### サンプル
クッキーの値を取得する
```nim
proc index(request:Request, params:Params):Future[Response] {.async.} =
  let val = newCookie(request).get("key")
```

クッキーに値を保存する
```nim
proc store*(request:Request, params:Params):Future[Response] {.async.} =
  let name = params.getStr("name")
  var cookie = newCookie(request)
  cookie.set("name", name)
  return render("with cookie").setCookie(cookie)
```

クッキーの有効期限を更新する
```nim
proc store*(request:Request, params:Params):Future[Response] {.async.} =
  var cookie = newCookie(request)
  cookie.updateExpire("name", 5)
  # cookie will be deleted after 5 days from now
  return render("with cookie").setCookie(cookie)
```

指定したキーのクッキーを削除する
```nim
proc index(request:Request, params:Params):Future[Response] {.async.} =
  var cookie = newCookie(request)
  cookie.delete("key")
  return render("with cookie").setCookie(cookie)
```

全てのクッキーを削除する
```nim
proc index(request:Request, params:Params):Future[Response] {.async.} =
  var cookie = newCookie(request)
  cookie.destroy()
  return render("with cookie").setCookie(cookie)
```

**⚠️ 本番環境ではクッキーは`Secure`と`HttpOnly`に設定されているので、JavaScriptでは読み込まれず、HTTPSでのみ使用できます。**


## セッション
Basolatoはファイルセッションのデータベースには[nimAES](https://github.com/jangko/nimAES)を使っています。

`newSession()`の引数に`sessionId`を設定すると、既存のセッションを返し、そうでなければ新しいセッションを作成します。

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

### サンプル
セッションIDを取得する
```nim
proc index(request:Request, params:Params):Future[Response] {.async.} =
  let sessionId = newSession().getToken()
```

セッションに値を保存する
```nim
proc store(request:Request, params:Params):Future[Response] {.async.} =
  let key = request.getStr("key")
  let value = request.getStr("value")
  discard newSession().set(key, value)
```

セッションに値が存在するかチェックして取得する
```nim
proc index(self:Controller):Future[Response] {.async.} =
  let sessionId = newCookie(self.request).get("session_id")
  let key = self.request.params["key"]
  let session = newSession(sessionId)
  var value:string
  if session.some(key):
    value = session.get(key)
```

セッションの1つの値を削除する
```nim
proc destroy(self:Controller):Future[Response] {.async.} =
  let sessionId = newCookie(self.request).getToken()
  let key = self.request.params["key"]
  discard newSession(sessionId).delete(key)
```

クライアントに紐付いた全てのセッションデータを削除する
```nim
proc destroy(self:Controller):Future[Response] {.async.} =
  let sessionId = newCookie(self.request).getToken()
  newSession(sessionId).destroy()
```
