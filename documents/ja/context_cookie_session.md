コンテキスト、クッキー、セッション
===
[戻る](../../README.md)

目次
<!--ts-->
* [コンテキスト、クッキー、セッション](#コンテキストクッキーセッション)
   * [ミドルウェア内でのチェック](#ミドルウェア内でのチェック)
      * [CSRFトークン](#csrfトークン)
   * [セッションDB](#セッションdb)
   * [Context](#context)
      * [API](#api)
      * [サンプル](#サンプル)
      * [複数のドメインにクッキーを作る時](#複数のドメインにクッキーを作る時)
   * [クッキー](#クッキー)
      * [API](#api-1)
      * [サンプル](#サンプル-1)
   * [セッション](#セッション)
      * [API](#api-2)
      * [サンプル](#サンプル-2)

<!-- Created by https://github.com/ekalinin/github-markdown-toc -->
<!-- Added by: root, at: Sat Jun 22 11:26:26 UTC 2024 -->

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

ビューに`${csrfToken()}`をセットします
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
# 403を返したい時
let res = await checkCsrfToken(r, p)
if res.isError:
  raise newException(Error403, "Error message")

# ログインページにリダイレクトさせたい時
let res = await checkCsrfToken(r, p)
if res.isError:
  raise newException(Error302, "/login")
```

## セッションDB
セッションには`File`か`Redis`が使えます。

ファイルセッションの時

config.nims
```nim
putEnv("SESSION_TYPE", "file")
putEnv(SESSION_DB_PATH, "/your/project/path/session.db") # db file path
```
.env
```env
SESSION_TIME=120
```

Redisセッションの時

config.nims
```nim
putEnv("SESSION_TYPE", "redis")
putEnv("SESSION_DB_PATH", "localhost:6379") # Redis IP address
```

.env
```env
SESSION_TIME=120
```

## Context
Basolatoは認証とセッションを内包した`Context`を持っています。

```nim
type Context* = ref object
  request: Request
  session*: Session
```

### API
インスタンス作成
```nim
proc new*(typ:type Context, context:Context, isCreateNew=false):Future[Context]{.async.}
```
---
セッションDBへのアクセス
```nim
proc set*(self:Context, key, value:string) {.async.} =

proc set*(self:Context, key:string, value:JsonNode) {.async.} =

proc some*(self:Context, key:string):Future[bool] {.async.} =

proc get*(self:Context, key:string):Future[string] {.async.} =

proc delete*(self:Context, key:string) {.async.} =

proc destroy*(self:Context) {.async.} =
```
---
認証
```nim
proc login*(self:Context) {.async.} =

proc isLogin*(self:Context):Future[bool] {.async.} =

proc logout*(self:Context) {.async.} =
```
---
クッキーから送られたセッションIDの取得
```nim
proc getToken*(self:Context):Future[string] {.async.} =
```
---
セッションDBのフラッシュデータへのアクセス
```nim
proc setFlash*(self:Context, key, value:string) {.async.} =

proc setFlash*(self:Context, key:string, value:JsonNode) {.async.} =

proc hasFlash*(self:Context, key:string):Future[bool] {.async.} =

proc getFlash*(self:Context):Future[JsonNode] {.async.} =

proc getValidationResult*(self:Context):Future[tuple[params:JsonNode, errors:JsonNode]] {.async.} =
```


### サンプル
ログイン
```nim
proc index(context:Context, params:Params):Future[Response] {.async.} =
  let email = params.getStr("email")
  let password = params.getStr("password")
  let userId = newLoginUsecase().login(email, password)
  await context.login()
  await context.set("id", $userId)
  return redirect("/")
```

ログアウト
```nim
proc index(context:Context, params:Params):Future[Response] {.async.} =
  if await context.isLogin():
    await context.logout()
  redirect("/")
```

セッションから値を取得する
```nim
proc index(context:Context, params:Params):Future[Response] {.async.} =
  let loginName = await context.get("login_name")
```

セッションに値を保存する
```nim
proc index(context:Context, params:Params):Future[Response] {.async.} =
  let name = params.getStr("name")
  await context.set("login_name", name)
  return render("auth")
```

セッションに値が存在するかチェックして取得する
```nim
proc index(context:Context, params:Params):Future[Response] {.async.} =
  var loginName:string
  if await context.some("login_name"):
    loginName = await context.get("login_name")
```

セッションの1つの値を削除する
```nim
proc destroy(context:Context, params:Params):Future[Response] {.async.} =
  await context.delete("login_name")
  return render("auth")
```

クライアントに紐付いた全てのセッションデータを削除する
```nim
proc destroy(context:Context, params:Params):Future[Response] {.async.} =
  await context.destroy()
  return render("auth")
```

フラッシュメッセージを保存する
```nim
proc store*(context:Context, params:Params):Response =
  await context.setFlash("success", "Welcome to the Sample App!")
  return redirect("/auth")
```

フラッシュメッセージを取得する
```nim
proc show*(self:Controller):Response =
  let flash = await context.getFlash("success")
  let user = newUserUsecase().show()
  return render(showHtml(user, flash))
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
proc new*(_:type Cookie, context:Context):Cookie =

proc get*(self:Cookie, name:string):string =

proc set*(self:var Cookie, name, value: string, expire:DateTime,
      sameSite: SameSite=Lax, secure = false, httpOnly = false, domain = "",
      path = "/") =

proc set*(self:var Cookie, name, value: string, sameSite: SameSite=Lax,
      secure = false, httpOnly = false, domain = "", path = "/") =

proc delete*(self:Cookie, key:string, path="/"):Cookie =

proc destroy*(self:Cookie, path="/"):Cookie =

proc setCookie*(response:Response, cookie:Cookie):Response =
```

### サンプル
クッキーの値を取得する
```nim
proc index(context:Context, params:Params):Future[Response] {.async.} =
  let val = Cookie.new(context.request).get("key")
```

クッキーに値を保存する
```nim
proc store*(context:Context, params:Params):Future[Response] {.async.} =
  let name = params.getStr("name")
  var cookie = Cookie.new(context.request)
  cookie.set("name", name)
  return render("with cookie").setCookie(cookie)
```

クッキーの有効期限を更新する
```nim
proc store*(context:Context, params:Params):Future[Response] {.async.} =
  var cookie = Cookie.new(context.request)
  let name = cookie.get("name")
  # クッキーは5日後に削除されます
  cookie.set("name", name, expire=timeForward(5, Days))
  return render("with cookie").setCookie(cookie)
```

指定したキーのクッキーを削除する
```nim
proc index(context:Context, params:Params):Future[Response] {.async.} =
  var cookie = Cookie.new(context.request)
  cookie.delete("key")
  return render("with cookie").setCookie(cookie)
```

全てのクッキーを削除する
```nim
proc index(context:Context, params:Params):Future[Response] {.async.} =
  var cookie = Cookie.new(context.request)
  cookie.destroy()
  return render("with cookie").setCookie(cookie)
```

**⚠️ 本番環境ではクッキーは`Secure`と`HttpOnly`が設定されているので、JavaScriptでは読み込まれず、HTTPSでのみ使用できます。**


## セッション
BasolatoはjsonファイルをローカルのセッションDBとしてを使うことができます。

`newSession()`の引数に`sessionId`を設定すると、既存のセッションを返し、そうでなければ新しいセッションを作成します。

```nim
Session* = ref object
  db: SessionDb
```

### API
```nim
proc newSession*(token=""):Future[Session] {.async.} =
  # 有効なトークンをセットすれば、存在してるセッションと接続します
  # 無効なトークンをセットすれば、新しくセッションを作ります

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
proc index(context:Context, params:Params):Future[Response] {.async.} =
  let sessionId = newSession().getToken()
```

セッションに値を保存する
```nim
proc store(context:Context, params:Params):Future[Response] {.async.} =
  let key = params.getStr("key")
  let value = params.getStr("value")
  discard newSession().set(key, value)
```

セッションに値が存在するかチェックして取得する
```nim
proc index(context:Context, params:Params):Future[Response] {.async.} =
  let sessionId = Cookie.new(context.request).get("session_id")
  let key = context.request.params["key"]
  let session = newSession(sessionId)
  var value:string
  if session.some(key):
    value = session.get(key)
```

セッションの1つの値を削除する
```nim
proc destroy(context:Context, params:Params):Future[Response] {.async.} =
  let sessionId = Cookie.new(context.request).getToken()
  let key = context.request.params["key"]
  discard newSession(sessionId).delete(key)
```

クライアントに紐付いた全てのセッションデータを削除する
```nim
proc destroy(context:Context, params:Params):Future[Response] {.async.} =
  let sessionId = Cookie.new(context.request).getToken()
  newSession(sessionId).destroy()
```
