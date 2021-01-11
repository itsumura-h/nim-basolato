ヘッダー
===
[戻る](../../README.md)

コンテンツ

<!--ts-->
   * [Headers](#headers)
      * [Request Header](#request-header)
      * [Response header](#response-header)
         * [Type of headers](#type-of-headers)
         * [Set headers in controller](#set-headers-in-controller)

<!-- Added by: root, at: Sun Dec 27 18:21:04 UTC 2020 -->

<!--te-->

## リクエストヘッダー
リクエストヘッダーを取得するには、`request.headers`を使ってください。

middleware/check_login.nim
```nim
import basolato/middleware

proc hasLoginId*(request:Request, params:Params):Future[Response] {.async.} =
  try:
    let loginId = request.headers["X-login-id"]
  except:
    raise newException(Error403, "Can't get login id")
```

app/controllers/sample_controller.nim
```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let loginId = request.headers["X-login-id"]
```

## レスポンスヘッダー
### Header型
`toHeaders()`関数は`array`、 `seq`、 `table`、`JsonNode`から`Header`を出力します。  
[サンプルコード](../../tests/test_header.nim)

```nim
let headers = [
  ("Strict-Transport-Security", ["max-age=63072000", "includeSubdomains"].join(", ")),
  ("X-Frame-Options", "SAMEORIGIN"),
  ("X-XSS-Protection", ["1", "mode=block"].join(", ")),
  ("X-Content-Type-Options", "nosniff"),
  ("Referrer-Policy", ["no-referrer", "strict-origin-when-cross-origin"].join(", ")),
  ("Cache-control", ["no-cache", "no-store", "must-revalidate"].join(", ")),
  ("Pragma", "no-cache"),
].toHeaders()
```


### コントローラーでレスポンスにヘッダーを設定する
`newHeaders()`関数で`Header`型のインスタンスを作り、`set`関数で値を追加し、最後に`render`関数の末尾に置きます。

```nim
proc index*(request:Request, params:Params):Future[Response] {.async.} =
  var header = newHeaders()
  header.set("Controller-Header-Key1", "Controller-Header-Val1")
  header.set("Controller-Header-Key1", "Controller-Header-Val2")
  header.set("Controller-Header-Key2", ["val1", "val2", "val3"])
  return render("with header", header)
```
