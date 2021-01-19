ミドルウェア
===
[戻る](../../README.md)

コンテンツ

<!--ts-->
   * [Middleware](#middleware)
      * [Routing middleware](#routing-middleware)

<!-- Added by: root, at: Sun Dec 27 18:20:43 UTC 2020 -->

<!--te-->

## API
```nim
proc middleware*(
  this:var Routes,
  path:Regex,
  action:proc(r:Request, p:Params):Future[Response]
) =

proc middleware*(
  this:var Routes,
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
import re
import basolato
import app/middlewares/auth_middleware

var routes = newRoutes()
routes.middleware(re".*", auth_middleware.checkLoginIdMiddleware)
serve(routes)
```

app/middleware/auth_middlware.nim
```nim
import asyncdispatch
import basolato/middleware


proc checkLoginId*(r:Request, p:Params):Future[Response] {.async.} =
  if not r.headers.hasKey("X-login-id"):
    raise newException(Error403, "リクエストヘッダーにX-login-idがありません")

  if not r.headers.hasKey("X-login-token"):
    raise newException(Error403, "リクエストヘッダーにX-login-tokenがありません")

  return next()
```

もしリクエストヘッダーに`X-login-id` or `X-login-token`のどちらかがなければ、403を返し、そうでなければ200を返します。

---

もしログインチェックに失敗した時にログインページにリダイレクトさせた時は、`ErrorRedirect`を使ってください。これは`Error 302`を呼び出します。

app/middleware/auth_middlware.nim
```nim
import basolato/middleware

proc checkLoginId*(r:Request, p:Params):Future[Response] {.async.} =
  if not r.headers.hasKey("X-login-id"):
    raise newException(ErrorRedirect, "/login")

  if not r.headers.hasKey("X-login-token"):
    raise newException(ErrorRedirect, "/login")
  return next()
```

---

CORSのように、コントローラーではなくミドルウェアで作られたレスポンスをクライアントに返したい時は、`next`関数の引数に設定することができます。
以下の例では、`setCorsMiddleware`は`OPTIONS`メソッドでのリクエストの時のみ動きます。

main.nim
```nim
var routes = newRoutes()
routes.middleware(@[HttpOptions], re"/api/.*", cors_middleware.setCorsMiddleware)
```

app/middleware/cors_middlware.nim
```nim
proc setCorsMiddleware*(r:Request, p:Params):Future[Response] {.async.} =
  let headers = corsHeader() & secureHeader()
  return next(status=Http204, headers=headers)
```
