ミドルウェア
===
[戻る](../../README.md)

目次
<!--ts-->


<!-- Created by https://github.com/ekalinin/github-markdown-toc -->
<!-- Added by: root, at: Sat Jun 22 10:33:03 UTC 2024 -->

<!--te-->

## API
```nim
proc middleware*(
  self:var Routes,
  path:Regex,
  action:proc(r:Request, p:Params):Future[Response]
) =

proc middleware*(
  self:var Routes,
  httpMethods:seq[HttpMethod],
  path:Regex,
  action:proc(r:Request, p:Params):Future[Response]
) =

proc next*(status:HttpCode=HttpCode(200), body="", headers:Headers=newHeaders()):Response =
```

## サンプル
ミドルウェアはコントローラーが呼ばれる前に実行されます。  
下のサンプルソースでは、`app/middleware/auth_middlware.nim`に定義されている`checkCsrfTokenMiddleware()`と`checkSessionIdMiddleware()`が動きます。

main.nim
```nim
import basolato
import app/middlewares/auth_middleware


let ROUTES = @[
  Route.get("/", welcome_rontroller.index)
    .middleware(auth_middleware.checkLoginIdMiddleware)
]

serve(routes)
```

app/middleware/auth_middlware.nim
```nim
import asyncdispatch
import basolato/middleware


proc checkLoginId*(r:Request, p:Params):Future[Response] {.async.} =
  if not r.headers.hasKey("X-login-id"):
    return render(Http403, "リクエストヘッダーにX-login-idがありません")

  if not r.headers.hasKey("X-login-token"):
    return render(Http403, "リクエストヘッダーにX-login-tokenがありません")

  return next()
```

もしリクエストヘッダーに`X-login-id` or `X-login-token`のどちらかがなければ、403を返し、そうでなければ200を返します。

---

ログインチェックが失敗した時にログインページにリダイレクトさせたい時は、`errorRedirect`関数を使うことができます。これは `HTTP 303`を返します。

app/middleware/auth_middlware.nim
```nim
import basolato/middleware

proc checkLoginId*(r:Request, p:Params):Future[Response] {.async.} =
  if not r.headers.hasKey("X-login-id"):
    return errorRedirect("/login")

  if not r.headers.hasKey("X-login-token"):
    return errorRedirect("/login")

  return next()
```

---

CORSのように、コントローラーではなくミドルウェアで作られたレスポンスをクライアントに返したい時は、`next`関数の引数に設定することができます。
以下の例では、`setCorsMiddleware`は`OPTIONS`メソッドでのリクエストの時のみ動きます。

main.nim
```nim
let ROUTES = @[
  Route.put("/api/user/{id:int}", user_controller.update)
    .middleware(cors_middleware.setCorsMiddleware),
]
```

app/middleware/cors_middlware.nim
```nim
proc setCorsMiddleware*(r:Request, p:Params):Future[Response] {.async.} =
  if r.httpMethod == HttpOption:
    let headers = corsHeader() & secureHeader()
    return next(status=Http204, headers=headers)
```
